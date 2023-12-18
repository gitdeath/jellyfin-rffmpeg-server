# jellyfin-rffmpeg-server

Official jellyfin docker image 10.8.12 with [rffmpeg](https://github.com/joshuaboniface/rffmpeg) (11/7/23) included.

```
Note: If used with my media_server yml then everything is handled automatically.
```

Manual usage only below:

The public ssh key is located inside the container at `/rffmpeg/.ssh/id_rsa.pub`
The known_hosts file is located inside the container at `/rffmpeg/.ssh/known_hosts`

You can add new hosts using these commands - the first copies the public key to the worker node and the second adds the worker node as a worker.

```
docker exec -it <Container Name> ssh-copy-id -i /rffmpeg/.ssh/id_rsa.pub <user>@<host>

docker exec -it <Container Name> rffmpeg add [--weight 1] [--name myfirsthost] <ip address of the host>
```

The user can be changed in the `rffmpeg.yml` file located at `/rffmpeg/`


You can check the status of rffmpeg using this:

```
docker exec -it <Container Name> rffmpeg status
```


When setting up hardware acceleration set the transcoding directory to `/transcodes` and ensure it is mounted to Jellyfin and all transcode workers with the NFS attributes of `sync` and `actimeo=1`


Use root user for ssh to your transcode worker
