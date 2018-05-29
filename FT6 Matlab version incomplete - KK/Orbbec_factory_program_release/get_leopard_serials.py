#!/cygdrive/c/Python27/python

'''
Requires windows python
Prints the serial numbers of all leopard devices currently connected
Note: replaces spaces with underscores.
'''

from _winreg import *
import sys
import re

aReg = ConnectRegistry(None, HKEY_LOCAL_MACHINE)

# Key lists all connected "generic parent" devices (composite devices)
# The serial number belongs to the composite device.
aKey = OpenKey(aReg, r"SYSTEM\CurrentControlSet\services\usbccgp\Enum")

# QueryValueEx returns a tuple (value, valueType)
count = QueryValueEx(aKey, "Count")[0]

id_strings = []

for i in xrange(count):
    try:
        the_string = QueryValueEx(aKey, str(i))
        id_strings.append(the_string[0])
    except:
        # Maybe it disappeared since we queried Count?
        # Don't care if so.
        pass

# Strings are of the format "...\VID_hhhh&PID_hhhh\serialNo"

id_strings_split = [s.split("\\") for s in id_strings]

id_strings_filtered = [
    s for s in id_strings_split if s[-2].upper() == "VID_2A0B&PID_00D3"]

# "prod" -- production behavior, error if we see multiple

if (len(sys.argv) > 1) and sys.argv[1] == "prod":
    if len(id_strings_filtered) > 1:
        print "MULTIPLE"
    elif len(id_strings_filtered) == 0:
        print "NONE"
    else:
        print re.sub(r"\W", "_", id_strings_filtered[0][-1])
else:
    for id_string in id_strings_filtered:
        print re.sub(r"\W", "_", id_string[-1])
