# webos1-bindca
Scripts to make using webOS 1 less painful.

## Instructions

### `05-date`
The date isn't being set properly on my webOS 1 dev board, which causes issues with certificate validity (among other things). I don't feel like figuring out why right now, so I just forced it to a more recent date on boot.

Put this script in `/var/lib/webosbrew/init.d` to make it run on boot. Make sure it's executable.

### `50-rebindca`
Remounts the modified CA certificate stores created by `bindca.sh`. `BIND_BASE` must match what's used in `bindca.sh`.

Put this script in `/var/lib/webosbrew/init.d` to make it run on boot. Make sure it's executable.

### `bindca.sh`
Run this once to set up copies of the system CA certificate stores with the ISRG X1 and X2 (Let's Encrypt) roots added. The copied directories will be created under `BIND_BASE`, which is set to `/var/lib/webosbrew/bindca` by default. `c_rehash` needs to be in the current directory and executable.

Don't set this one up to automatically run on boot.

Based on [50-customca](https://gist.github.com/Informatic/d7bcdd59eac16ffbffd3a5b5c24b4195) by [Piotr Dobrowolski](https://gist.github.com/Informatic).

### `c_rehash`
This is used by `bindca.sh`. It must have execute permission and be in the current directory when `bindca.sh` is run.

The author of `c_rehash` is Ben Secrest. It is a shell script reimplementation of the original Perl `c_rehash` that was part of OpenSSL.
It was obtained from [OpenEmbedded](https://github.com/openembedded/openembedded-core/blob/rocko/meta/recipes-connectivity/openssl/openssl-1.0.2o/openssl-c_rehash.sh).
It's licensed separately from the scripts written by me and seems to use the OpenSSL license.

## License
This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along
with this program. If not, see <https://www.gnu.org/licenses/>.

See `LICENSE` for details.
