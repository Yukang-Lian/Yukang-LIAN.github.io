---
title: 用brpc中的bvar替换Doris的Metrics(WIP)
date: 2023-01-03 17:44:05
categories: Doris
tags: [Doris, Metrics, Bvar]
---

# 背景

Doris作为分布式数据库，监控告警和运维服务离不开指标监控，当前Doris的Metric是使用的一套自己设计的架构，此架构于两年前完成并没有进行频繁的更新，考虑到效率的原因，准备用brpc的bvar来替代Doris的Metric，以提升运行效率。

# 1. Metric的实现

## 1.1 Metric的注册

以 `doris_be_active_scan_context_count` 此metric为例研究设计模式。

首先定义了一个 `METRIC_PROTOTYPE` ，具体定义如下：

```cpp
DEFINE_GAUGE_METRIC_PROTOTYPE_2ARG(active_scan_context_count, MetricUnit::NOUNIT);

#define DEFINE_GAUGE_METRIC_PROTOTYPE_2ARG(name, unit) \
    DEFINE_METRIC_PROTOTYPE(name, MetricType::GAUGE, unit, "", "", Labels(), false)

#define DEFINE_METRIC_PROTOTYPE(name, type, unit, desc, group, labels, core) \
    ::doris::MetricPrototype METRIC_##name(type, unit, #name, desc, group, labels, core)
```

实际上定义了一个 `MetricPrototype` 结构体，具体定义如下：

```cpp
struct MetricPrototype {
public:
    MetricPrototype(MetricType type_, MetricUnit unit_, std::string name_,
                    std::string description_ = "", std::string group_name_ = "",
                    Labels labels_ = Labels(), bool is_core_metric_ = false)
            : is_core_metric(is_core_metric_),
              type(type_),
              unit(unit_),
              name(std::move(name_)),
              description(std::move(description_)),
              group_name(std::move(group_name_)),
              labels(std::move(labels_)) {}

    std::string simple_name() const;
    std::string combine_name(const std::string& registry_name) const;
    std::string to_prometheus(const std::string& registry_name) const;

    bool is_core_metric;
    MetricType type;
    MetricUnit unit;
    std::string name;
    std::string description;
    std::string group_name;
    Labels labels;
};
```

结构体内有三个方法， `simple_name()` 返回传入的 `name` ，`combine_name(registry_name)` 返回添加了头部的 `name` ，最后一个方法是 `to_prometheus(registry_name)` ，返回一个更加复杂的 `name` 。