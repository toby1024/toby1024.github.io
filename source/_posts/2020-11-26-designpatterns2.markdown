---
layout: post
title: "设计模式-创建型"
date: 2020-11-26 14:47:26 +0800
comments: true
categories: DesignPatterns
keyswords: 设计模式 工厂模式
description: 设计模式-创建型
---
{% img /images/DesignPatterns/20201126144901.jpg %}
<!--more-->
## 单例模式
单例模式，顾名思义就是一个类只有一个实例。
单例主要的好处就是，1:可以解决资源访问冲突的问题。2:减少资源浪费。

### 单例的实现方式

1:饿汉式

在类加载的时候就实力化对象，不支持延迟加载。
```java
public class HungryDemo {
    private AtomicInteger id = new AtomicInteger(0);
    public static HungryDemo instance = new HungryDemo();

    private HungryDemo() {
    }

    public static HungryDemo getInstance() {
        return instance;
    }

    public int getId() {
        return id.incrementAndGet();
    }

    public static void main(String[] args) {
        for (int i = 0; i < 10; i++) {
            new Thread(() -> {
                try {
                    Thread.sleep(new Random().nextInt(10000));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                HungryDemo instance = HungryDemo.getInstance();
                System.out.println(instance + "==>" + instance.getId());
            }).start();
        }
    }
}
```

2:懒汉式

支持延迟加载，在使用的时候才真正加载。
```java
public class LazyDemo {
    private AtomicInteger id = new AtomicInteger(0);

    public static LazyDemo instance;

    private LazyDemo() {
    }

    public static synchronized LazyDemo getInstance() {
        if (Objects.isNull(instance)) {
            instance = new LazyDemo();
        }
        return instance;
    }

    public int getId() {
        return id.incrementAndGet();
    }
    public static void main(String[] args) {
        for (int i = 0; i < 10; i++) {
            new Thread(() -> {
                try {
                    Thread.sleep(new Random().nextInt(10000));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                LazyDemo instance = LazyDemo.getInstance();
                System.out.println(instance + "==>" + instance.getId());
            }).start();
        }
    }
}
```
饿汉和懒汉的区别就是一个支持延迟加载，一个不支持。懒汉模式还要加锁，防止并发问题。从这一点来看，懒汉模式性能是不如饿汉模式，饿汉模式在类加载时就进行实力化，也可以提前将实力化过程中发生的资源不足等问题提前暴露，而不是等到业务访问后才发现无法进行初始化，引发线上事故。
但这两种都有各自的不足，所以现在有第三种方式。

3:双重检测
```java
public class DoubleCheckDemo {
    private AtomicInteger id = new AtomicInteger(0);
    public static DoubleCheckDemo instance;

    private DoubleCheckDemo() {
    }

    public static DoubleCheckDemo getInstance() {
        if (Objects.isNull(instance)) {
            synchronized (DoubleCheckDemo.class) {
                System.out.println("加锁操作");
                if (Objects.isNull(instance)) {
                    instance = new DoubleCheckDemo();
                }
            }
        }
        return instance;
    }

    public int getId() {
        return id.incrementAndGet();
    }

    public static void main(String[] args) {
        for (int i = 0; i < 10; i++) {
            new Thread(() -> {
                try {
                    Thread.sleep(new Random().nextInt(10000));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                DoubleCheckDemo instance = DoubleCheckDemo.getInstance();
                System.out.println(instance + "==>" + instance.getId());
            }).start();
        }
    }
}
```
双重检测解决了懒汉模式的并发性能问题，同时支持懒加载。

4:静态内部类

静态内部类的实现比双重检测要更加简单，同时也能做到懒加载。
```java
public class InnerClassDemo {

    private AtomicInteger id = new AtomicInteger(0);

    private InnerClassDemo() {
    }

    private static class InnerClassDemoHolder {
        private static final InnerClassDemo instance = new InnerClassDemo();
    }

    public static InnerClassDemo getInstance() {
        return InnerClassDemoHolder.instance;
    }

    public int getId() {
        return id.incrementAndGet();
    }

    public static void main(String[] args) {
        for (int i = 0; i < 10; i++) {
            new Thread(() -> {
                try {
                    Thread.sleep(new Random().nextInt(10000));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                InnerClassDemo instance = InnerClassDemo.getInstance();
                System.out.println(instance + "==>" + instance.getId());
            }).start();
        }
    }
}
```
`InnerClassDemoHolder` 是静态内部类，一开始并不会加载，等到调用`getInstance()`方法时才会被加载，这是一种无锁的实现，线程安全由jvm来保证。

5:枚举

采用枚举的方式来实现是最简单的方式。
```java
public enum EnumDemo {
    INSTANCE;
    private AtomicInteger id = new AtomicInteger(0);

    public int getId() {
        return id.incrementAndGet();
    }
}
public class EnumDemoTest {
    public static void main(String[] args) {
        for (int i = 0; i < 10; i++) {
            new Thread(() -> {
                try {
                    Thread.sleep(new Random().nextInt(10000));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                EnumDemo instance = EnumDemo.INSTANCE;
                System.out.println(instance + "==>" + instance.getId());
            }).start();
        }
    }
}
```
### 单例模式的问题
- 单例对OOP特性的支持不友好，单例对继承，多态特性支持不友好，违背了面向抽象编程的思想。
- 单例对代码的扩展性不好。
- 单例对代码的测试性不好，单例往往硬编码进业务，后续mock不方便，需要在一开始就对单例进行包装。
- 单例不支持有参数的构造函数，单例的设计是无状态的，就无法进行参数传递来构建实例。

### 单例的范围
如果需要在线程内实现单例，可以使用ThreadLocal并发工具类。

如果需要在集群环境下实现单例，可以借助外部共享存储，例如redis。当进行实例创建的时候，从外部存储加载对象，如果没有则创建后存储回去，这里需要分布式锁的接入，实现起来比较麻烦。

## 工厂模式
### 简单工厂
简单工厂可以看作是将对象的创建抽取出来独立的一种实现，这种实现方式比较简单，目的就是将创建对象的负责业务代码从业务中剥离出来，实现复用。
缺点是逻辑过于集中，不利于后续扩展。

### 工厂方法
工厂方法模式是简单工厂的进一步抽象。使用面向对象的多态性，保持了简单工厂的的优点。将不同的构建逻辑分开到不同的实现中，避免了修改单个逻辑影响所有的构建逻辑。

### 抽象工厂
抽象工厂提供一个抽象，而不是具体实现。符合面向抽象编程思想，增加工厂也不影响具体业务代码。

## 建造者模式
比较典型的实现是lombok的builder方法。
```java
public class BuilderDemo {
    private String name;
    private int age;
    private String phone;
    private String email;

    private BuilderDemo(BuilderDemoBuilder builder) {
        this.name = builder.name;
        this.age = builder.age;
        this.phone = builder.phone;
        this.email = builder.email;
    }

    public static class BuilderDemoBuilder {
        private String name;
        private int age;
        private String phone;
        private String email;

        public BuilderDemo build() {
            return new BuilderDemo(this);
        }

        public BuilderDemoBuilder setName(String name) {
            if (Objects.isNull(name)) {
                throw new IllegalArgumentException("name must not null");
            }
            this.name = name;
            return this;
        }

        public BuilderDemoBuilder setAge(int age) {
            this.age = age;
            return this;
        }

        public BuilderDemoBuilder setPhone(String phone) {
            if (Objects.isNull(name)) {
                throw new IllegalArgumentException("phone must not null");
            }
            this.phone = phone;
            return this;
        }

        public BuilderDemoBuilder setEmail(String email) {
            this.email = email;
            return this;
        }
    }

    public static void main(String[] args) {
        BuilderDemo build = new BuilderDemoBuilder().setAge(18).setEmail("email").setName("name").setPhone("13812340987").build();
        System.out.println(build.name);
    }
}
```

## 原型模式
基于已有对象原型创建对象。

实现方式分为深拷贝和浅拷贝。深拷贝需要递归负责，创建一个完全独立的对象。浅拷贝只是拷贝引用地址，适合不会变的对象。