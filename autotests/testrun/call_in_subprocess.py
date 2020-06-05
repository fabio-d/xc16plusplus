import base64
import multiprocessing.connection
import os
import pickle
import subprocess
import sys
from traceback import print_exception
from typing import Callable, Optional


class CallAndCaptureOutputResult:
    def __init__(self, value, value_is_exception, output):
        if value_is_exception:
            self.exception = value
        else:
            self.exception = None
            self.result = value

        self.output = output

    def __repr__(self):
        if self.exception is None:
            return 'CallAndCaptureOutputResult(result=%r, output=%r)' \
                   % (self.result, self.output)
        else:
            return 'CallAndCaptureOutputResult(exception=%r, output=%r)' \
                   % (self.exception, self.output)


def call_and_capture_output(func, timeout=None):
    """
    Call function in a separate process while logging its stdout/stderr.

    :param func: The target function (taking no arguments) to be called. It is
                 transparently serialized (with the pickle library),
                 injected into the spawned subprocess and called. Its return
                 value is then serialized (again, with the pickle library) and
                 transferred back into the master process.
    :type func: Callable
    :param timeout: An optional timeout, in seconds. In case of timeout, a
                    subprocess.TimeoutExpired exception will be stored in the
                    returned CallAndCaptureOutputResult instance.
    :type timeout: Optional[float]
    :return: A CallAndCaptureOutputResult instance with the return value (or an
             exception, in case of error) and combined stdout+stderr output.
    :rtype: CallAndCaptureOutputResult
    """

    authkey = os.urandom(16)

    with multiprocessing.connection.Listener(authkey=authkey) as listener:
        cmdline = [sys.executable,
                   '-u',  # disable output buffering in subprocess
                   'testrun/call_in_subprocess.py',
                   '_SLAVE_call_and_capture_output', listener.address]

        with subprocess.Popen(cmdline,
                              stdin=subprocess.PIPE,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT) as proc:
            # Send authentication key over standard input
            proc.stdin.write(base64.b16encode(authkey))
            proc.stdin.close()

            # Wait for the slave to connect
            slave = listener.accept()

            # Send python paths and the job (i.e. the function to be called) to
            # the slave process
            slave.send(sys.path)
            slave.send(func)

            # Collect its output until EOF  - TODO: add support for timeout
            output = b''
            while True:
                new_output = proc.stdout.read(1)
                if len(new_output) == 0:
                    break  # EOF reached

                sys.stderr.buffer.write(new_output)  # tee to master's stderr
                output += new_output

            value, value_is_exception = slave.recv()
            proc.wait()

    return CallAndCaptureOutputResult(value, value_is_exception, output)


def _do_slave(address):
    # Receive authentication key over standard input
    authkey = base64.b16decode(sys.stdin.read())

    # Connect back to the master
    master = multiprocessing.connection.Client(address=address, authkey=authkey)

    # Receive python path and job (i.e. the function to be called) from the
    # master process
    sys.path = master.recv()
    func = master.recv()

    # Run it
    try:
        result = (func(), False)
    except:
        type, value, traceback = sys.exc_info()
        print_exception(type, value, traceback)

        result = (value, True)

    # Closing the output tells the master that a result is ready. However,
    # instead of simply calling master.send(result) after closing the output,
    # we pickle the result in advance, so that pickling errors have a chance to
    # be printed to stderr.
    # Note: sys.stdout.close() will not really close the stream, we have to use
    # os.close instead. This is documented in python's library FAQ (the same
    # applies to sys.stderr).
    pickled_result = pickle.dumps(result)
    sys.stdout.flush()
    os.close(sys.stdout.fileno())
    sys.stderr.flush()
    os.close(sys.stderr.fileno())
    master.send_bytes(pickled_result)  # equivalent to master.send(result)


if __name__ == '__main__':
    if len(sys.argv) != 3 or sys.argv[1] != '_SLAVE_call_and_capture_output':
        exit("This program is meant to be invoked by this module's "
             "call_and_capture_output function, NOT directly!")

    _do_slave(sys.argv[2])
