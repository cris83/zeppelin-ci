# ZeppelinCI

ZeppelinCI is a build system for Apache Zeppelin.

ZeppelinCI can 
* classloading test at the spark cluster in actual environment.
* test on the various Operation System environments and JDK.
* test on the various spark cluster environments.
* run parallel environment build.


### Requirements
* Jenkins
* Docker
* make


### Structure
![alt tag](https://cloud.githubusercontent.com/assets/3348133/11333590/2b1d8506-9212-11e5-84a7-7e2a052d0bd3.png)
* ZeppelinCI is using `Docker` to handle three or more jobs at the same time in parallel.


### Getting Started
ZeppelinCI is about three item
```
]# make

  Several choices : 

   make build     to build all docker image.
   make run       to run all docker container.

   example) make build type=zeppelin item=spark_standalone 

  type : 

   backend        jobs for backends.
   zeppelin       jobs for zeppelin.

  sub item : 
  examples) 
   *              all items in the build system will be ran.
   spark_*        all spark cluster will be builded or ran.
```

If you want to build `Docker Images`, then :
```
]# make build type=[backend|zeppelin] item=[spark_standalone|spark_mesos|spark_yarn]
```

If you want to run `Docker Container`, then :
```
]# make run type=[backend|zeppelin] item=[spark_standalone|spark_mesos|spark_yarn] \
   REPO=[your repository-url] BRANCH=[your branch]
```
* REPO & BRANCH : this parameter write your repository and branch that requested the `PR`.
* In Jenkins, Supports the environment variable about `REPO & BRANCH` of requested the `PR`.


### ScreenShots
* When created PR or push.
![alt tag](https://cloud.githubusercontent.com/assets/8110426/11338319/bc717494-9236-11e5-876d-b219248c1f1f.png)

* When completed build.
![alt tag](https://cloud.githubusercontent.com/assets/8110426/11338683/dccfcefa-9238-11e5-9477-387fbcf0e184.png)
