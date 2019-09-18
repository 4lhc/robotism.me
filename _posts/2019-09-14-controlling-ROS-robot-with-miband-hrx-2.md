---
layout: post
title:  "Controlling ROS Turtlebot3 with Miband - Part II"
date:   2019-09-14
excerpt: "Coding a Xiaomi Miband Controller for ROS Gazebo Turtlebot3 simulation."
comments: true
image: "/images/controlling-ROS-robot-with-miband-hrx-2-img01.png"
image1: "/images/controlling-ROS-robot-with-miband-hrx-1-img02.png"
image2: "/images/controlling-ROS-robot-with-miband-hrx-1-img03.gif"
gh_file1: "https://github.com/4lhc/ROS/blob/master/learning_ws/src/x1_miband_control/src/generic_robot.py"
gh_file2: "https://github.com/4lhc/ROS/blob/e8adca517d6d338cf86a63c005fb4a2c9cdcdf44/learning_ws/src/x1_miband_control/bin/miband_controller.py"
jupyter_NB: ""
categories: [ROS]
tags: [MiBand, BLE, ROS, python, git]
---

After successfully establishing communication [(read Part I)]({% post_url 2019-09-05-controlling-ROS-robot-with-miband-hrx-1 %}) with the MiBand HRX, we can start writing the controller node.

We will start by setting up project ros package.

### 1. Setup
Create a package named ``x1_miband_control`` with a dependency on rospy.
{% highlight bash %}
catkin_create_pkg x1_miband_control rospy
cd x1_miband_control/src
{% endhighlight %}

We have three other runtime dependencies to make the MiBand controller work. [PyCrypto](https://github.com/dlitz/pycrypto), [bluepy](https://github.com/IanHarvey/bluepy) & the [MiBand HRX](https://github.com/4lhc/MiBand_HRX) library that we created in Part I.
Once inside the ``x1_miband_control/src`` directory we can clone the dependencies. Make sure that you checkout the right versions

{% highlight bash %}
git clone -n https://github.com/4lhc/MiBand_HRX
cd MiBand_HRX
git checkout 1711a218ab66bfba25aa7de717452574301dcba5
{% endhighlight %}

Repeat the same for the other dependencies. From ``xi_miband_control/src``
{% highlight bash %}
git clone -n https://github.com/dlitz/pycrypto
cd pycrypto
git checkout 7fd528d03b5eae58eef6fd219af5d9ac9c83fa50
cd ..
git clone -n https://github.com/IanHarvey/bluepy
cd bluepy
git checkout dc33285f31a873fab92c22e8839c44899f82b041
{% endhighlight %}

Bluepy and pycrypto has to be built and installed using setup.py inside their respective directories. I am yet to find a way to automate the build of these dependencies using CmakeLists.txt. Inside both bluepy & pycrypto directories run,

{% highlight bash %}
python setup.py build && python setup.py install
{% endhighlight %}

Furthermore, I had to move ``xi_miband_control/src/bluepy/bluepy`` to ``xi_miband_control/src/bluepy`` inorder for bluepy to work.


Next, we will create a setup.py in out package root with the following content and uncomment the ``catkin_python_setup()`` macro in ``CmakeLists.txt`` to make sure that our dependencies get installed.

{% highlight python %}
{% github_sample /4lhc/ROS/blob/0006a7ac12131a579777117e9cc4e1e5f31f805e/learning_ws/src/x1_miband_control/setup.py %}
{% endhighlight %}
<!--{% github_sample_ref /4lhc/ROS/blob/0006a7ac12131a579777117e9cc4e1e5f31f805e/learning_ws/src/x1_miband_control/setup.py %}-->


Finally, run ``catkin_make`` from the catkin workspace root to build everything.


### 2. MiBand Controller

We will start by importing the necessary modules. Multithreading is used to prevent the ``band.start_raw_data_realtime()`` method from blocking.
[``generic_robot``]({{page.gh_file1}}) contains a simple ``Robot()`` class definition.


[``vel_control()``]({{page.gh_file2}}#L42) method sets the robot's linear x velocity to a value proportional to the pitch of the MiBand and the angular z velocity to a value proportional to MiBand's roll. It also applies a low pass filter to the roll & pitch.

[``start_control()``]({{page.gh_file2}}#L27) will run as long as data is available from the MiBand. If the robot crashes into a wall, the method sends a vibration alert to the MiBand.


{% gist d42bba11b870be4c5860b00256fbec27 %}

### 3 Test Run

{% include youtube.html id="Zg9SUYd6MYA" width="80%" %}

### 4 Next
This was a fun project. It still requires a lot of improvements. If time permits, I would like to build a game of tag, with multiple MiBand controlled robots in gazebo -- would be cool!
