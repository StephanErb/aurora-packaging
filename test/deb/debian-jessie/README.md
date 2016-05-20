# Installing Aurora

## Install packages

Two methods are described, one for installing locally built packages, the other
for installing released packages or release candidate packages.

### Locally built

    # Install vagrant scp
    vagrant plugin install vagrant-scp

    # Scp over the newly built packages
    for deb in ../../../artifacts/aurora-debian-jessie/dist/*.deb; do
      vagrant scp $deb :$(basename $deb)
    done

    # Install each rpm
    vagrant ssh -- -L8081:localhost:8081 -L1338:localhost:1338
    sudo dpkg -i *.deb

### Released

    vagrant ssh -- -L8081:localhost:8081 -L1338:localhost:1338
    version=0.12.0
    pkg_root="https://bintray.com/artifact/download/apache/aurora/"
    for deb in \
        aurora-scheduler_${version}_amd64.deb \
        aurora-executor_${version}_amd64.deb \
        aurora-tools_${version}_amd64.deb; do
      wget $pkg_root/$deb
      sudo dpkg -i $deb
    done

## Initialize and start

The scheduler and observer will automatically start when installed. However, teh replicated log
has to be initialized manually:

    sudo systemctl stop aurora-scheduler
    sudo -u aurora mkdir -p /var/lib/aurora/scheduler/db
    sudo -u aurora mesos-log initialize --path=/var/lib/aurora/scheduler/db
    sudo systemctl start aurora-scheduler

## Create a job

    echo "
    task = SequentialTask(
      processes = [Process(name = 'hello', cmdline = 'echo hello')],
      resources = Resources(cpu = 0.5, ram = 128*MB, disk = 128*MB))
    jobs = [Service(
      task = task, cluster = 'example', role = 'www-data', environment = 'prod', name = 'hello')]" > hello_world.aurora

    aurora job create example/www-data/prod/hello hello_world.aurora

## Troubleshooting

* Mesos: `/var/log/mesos`
* Aurora scheduler: `sudo journalctl -u aurora-scheduler`
* Aurora observer: `/var/log/aurora/thermos_observer.log`
