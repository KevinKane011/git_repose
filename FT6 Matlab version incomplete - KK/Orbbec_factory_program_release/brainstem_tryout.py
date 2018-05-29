#!/usr/bin/env python
""" What it do. """
###############################################################################
###                                                                         ###
###                               Dependencies                              ###
###                                                                         ###
###############################################################################
import argparse
import brainstem
import os
import platform
import sys
import time

from brainstem.result import Result

# Import some helpers
OS_NAME = platform.system()
if OS_NAME == "Windows": REPO_LOC = "C:/dev/mp_production/"
else: REPO_LOC = os.environ["HOME"] + "/mp_production/"

###############################################################################
###                                                                         ###
###                             Global Variables                            ###
###                                                                         ###
###############################################################################
debug   = False
verbose = False

disable  = False
enable   = False
port_num = None

###############################################################################
###                                                                         ###
###                        Global Lists/Dictionaries                        ###
###                                                                         ###
###############################################################################



###############################################################################
###                                                                         ###
###                                 Classes                                 ###
###                                                                         ###
###############################################################################
class usb_hub(object):
    def __init__(self):
        self.hub    = None
        self.serial = None
        self.stem   = None

        self.stem = brainstem.stem.USBStem()

        result = self.stem.discoverAndConnect(brainstem.link.Spec.USB)

        if result != 0:
            self.handle_error(result, "Error: Could not connect to device")

        self.serial = self.stem.system.getSerialNumber().value

        self.hub = brainstem.stem.USB(self.stem,0)

    def close(self):
        self.stem.disconnect()

    def disable_port(self, port_num):
        result = self.hub.setPortDisable(port_num)
        if result != 0:
            self.handle_error( "Error disabling port %i"%port_num, code=2 )

    def enable_port(self, port_num):
        result = self.hub.setPortEnable(port_num)
        self.hub.setSuperSpeedDataEnable(port_num)
        if result != 0:
            self.handle_error( "Error enabling port %i"%port_num, code=3 )

    def handle_error(self, result, msg="Error: ", code=1):
        if code != 0 or verbose: print "%s(%r)" % (msg,result)
        if code != 0: sys.exit(code)

###############################################################################
###                                                                         ###
###                                Functions                                ###
###                                                                         ###
###############################################################################
def ArgParser():
    """ This function will handle the input arguments while keeping the main
        function tidy. """

    usage = """
    script_name.py flags

    This script is for .

            """

    parser = argparse.ArgumentParser( description = "Description",
                                      usage = usage)

    parser.add_argument( "--debug",
                         action  = "store_const",
                         const   = True,
                         default = False,
                         dest    = "debug",
                         help    = "Run in debug mode." )

    parser.add_argument( "--disable",
                         action  = "store_const",
                         const   = True,
                         default = False,
                         dest    = "disable",
                         help    = "Disable a port specified by '-p'" )

    parser.add_argument( "--enable",
                         action  = "store_const",
                         const   = True,
                         default = False,
                         dest    = "enable",
                         help    = "Enable a port specified by '-p'" )

    parser.add_argument( "-p",
                         const   = True,
                         default = False,
                         dest    = "port_num",
                         help    = "The port number to operate on",
                         nargs   = '?',
                         type    = int )

    parser.add_argument( "-v",
                         action  = "store_const",
                         const   = True,
                         default = False,
                         dest    = "verbose",
                         help    = "Make this script a chatterbox." )

    args = parser.parse_args()

    global debug, verbose
    debug = args.debug
    verbose = args.verbose

    if type(args.port_num) != int:
        if not args.port_num:
            print "\n*** ERROR: use the '-p' flag to specify a port to control! ***"
            sys.exit(100)

        else:
            print "\n*** ERROR: What port number do you want to control? ***"
            sys.exit(101)
    else:
        global disable, enable, port_num
        port_num = args.port_num

        disable = args.disable
        enable = args.enable

        if enable and disable:
            print "\n*** ERROR: Either enable or disable, but not both. ***"

if __name__ == "__main__":
    ArgParser()

    if verbose:
        print "port number = %i" % port_num
        print "enable = %r" % enable
        print "disable = %r" % disable

    hub = usb_hub()

    if disable: hub.disable_port(port_num)
    elif enable: hub.enable_port(port_num)

    hub.close()
