# Copyright 2017-present Open Networking Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""
Common utility functions
"""

from loxi.pp import PrettyPrinter

# ReservedVlan Transparent Vlan (Masked Vlan, VLAN_ANY in ONOS Flows)

RESERVED_TRANSPARENT_VLAN = 4096

def pp(obj):
    pp = PrettyPrinter(maxwidth=80)
    pp.pp(obj)
    return str(pp)

def mac_str_to_tuple(mac):
    """
    Convert 'xx:xx:xx:xx:xx:xx' MAC address string to a tuple of integers.
    Example: mac_str_to_tuple('00:01:02:03:04:05') == (0, 1, 2, 3, 4, 5)
    """
    return tuple(int(d, 16) for d in mac.split(':'))