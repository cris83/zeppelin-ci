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
![image](https://cloud.githubusercontent.com/assets/8110426/11679999/a07fef90-9e98-11e5-93a1-2ca8084e4040.png)
* ZeppelinCI is using `Docker` to run one or more build jobs in parallel at the same time.

### Getting Started
As follows, Zeppelin CI provide two command to `docker image` creation and `docker container` running.
It also has three items for supporting an interpreter.
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

Supports currently items are :
```
 > spark_standalone
 > spark_mesos
 > spark_yarn
```

To make docker images:
```
]# make build type=[backend|zeppelin] item=[spark_standalone|spark_mesos|spark_yarn]
```

To run docker containers:
```
]# make run type=[backend|zeppelin] item=[spark_standalone|spark_mesos|spark_yarn] \
   REPO=[your repository-url] BRANCH=[your branch]
```
* REPO & BRANCH : this parameter write your repository and branch that requested the `PR`.
* In Jenkins, Supports the environment variable about `REPO & BRANCH` of requested the `PR`.


### ScreenShots
* When created PR or push.
![image](https://cloud.githubusercontent.com/assets/8110426/11338319/bc717494-9236-11e5-876d-b219248c1f1f.png)

* When completed build.
![image](https://cloud.githubusercontent.com/assets/8110426/11338683/dccfcefa-9238-11e5-9477-387fbcf0e184.png)
