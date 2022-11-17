# jellyfin-rffmpeg-server

Official jellyfin docker image with [rffmpeg](https://github.com/joshuaboniface/rffmpeg) included.

The public ssh key is located in `/config/rffmpeg/.ssh/id_rsa.pub`

You can add new hosts using this:

```
docker compose exec -it jellyfin rffmpeg add [--weight 1] [--name myfirsthost] <ip address of the host>
```
