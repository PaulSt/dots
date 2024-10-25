# dots
My dot files


## notes 
 My not very elegant solution to this problem is to keep copies of 2 rules files which I then (as ROOT) insert into /etc/polkit-1/rules.d after a new installation. Be aware of lowered security when using these at your own risk!

10-udisks2.rules >

// Allow udisks2 to mount devices without authentication
// for users in the "storage" group.
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
         action.id == "org.freedesktop.udisks2.filesystem-mount") &&
	subject.isInGroup("storage")) {
        return polkit.Result.YES;
    }
});

20-shutdown-reboot.rules >

// Rule to allow inactive users in wheel group to reboot or shutdown
//
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.consolekit.system.stop" ||
         action.id == "org.freedesktop.consolekit.system.restart") &&
        subject.isInGroup("wheel")) {
            return polkit.Result.YES;
    }
});

## using iwd + systemd-resolved
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

Edit or create: /etc/iwd/main.conf

    [General]
    EnableNetworkConfiguration=true

    [Network]
    NameResolvingService=systemd


    
Create: /etc/systemd/resolved.conf.d/dns_servers.conf with your desired DNS servers. These are for Cloudflare's. 8.8.8.8 would be Google's.

[Resolve]
DNS=1.1.1.1 1.0.0.1
Domains=~.

systemctl enable iwd.service systemd-resolved.service
