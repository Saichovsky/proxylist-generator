# Proxylist-Generator v0.1

Here's a shell script that I use to harvest anonymous SOCKS5 proxy servers for use with [JDownloader](http://www.jdownloader.org/jdownloader2). You may use AWK to modify the output further.

The script retrieves SOCKS5 IP addresses (and ports) from two sources and tests them for speed and functionality before weeding out the non-working addresses.

## Usage

```
sh proxylist-generator.sh
```

## License

This software is licensed under the GNU GPLv3 license.
