# jellyfin-rffmpeg-server

Official jellyfin docker image with [rffmpeg](https://github.com/joshuaboniface/rffmpeg) included.

The public ssh key is located inside the container at `/config/rffmpeg/.ssh/id_rsa.pub`
The known_hosts file is located inside the container at `/config/rffmpeg/.ssh/known_hosts`

You can add new hosts using these commands - the first copies the public key to the worker node and the second adds the worker node as a worker.

```
docker exec -it <Container Name> ssh-copy-id -i /config/rffmpeg/.ssh/id_rsa.pub <user>@<host>

docker exec -it <Container Name> rffmpeg add [--weight 1] [--name myfirsthost] <ip address of the host>
```

The user can be changed in the `rffmpeg.yml` file located at `/config/rffmpeg/`


You can check the status of rffmpeg using this:

```
docker exec -it <Container Name> rffmpeg status
```


When setting up hardware acceleration set the transcoding directory to `/transcodes`
