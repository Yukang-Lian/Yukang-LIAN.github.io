---
title: 用brpc中的bvar替换Doris的Metrics(WIP)
date: 2023-01-03 17:44:05
categories: Doris
tags: [Doris, Metrics, Bvar]
---

### 背景

Doris作为分布式数据库，监控告警和运维服务离不开指标监控，当前
