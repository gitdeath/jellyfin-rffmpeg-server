# jellyfin-rffmpeg-server

Official jellyfin docker image 10.8.13 with [rffmpeg](https://github.com/joshuaboniface/rffmpeg) (12/18/23) included.


Note: If used with my [media_server](https://github.com/gitdeath/media_server) then everything is handled automatically.
 - Automatically scale the rffmpeg add / removes based on the number of worker nodes
 - Rffmpeg init and SSH with rsa to worker nodes.
 - SSH to nodes are not done with elevation to prevent security issues.
