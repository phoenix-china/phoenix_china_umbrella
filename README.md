# Phoenix 中文社区

[![Build Status](https://travis-ci.org/phoenix-china/phoenix_china_umbrella.svg?branch=master)](https://travis-ci.org/phoenix-china/phoenix_china_umbrella)

## 依赖
1. elixir >= 1.4.2
2. phoenix >= 1.3.0-rc.1
3. postgresql >= 9.6
4. node >= 7.2.0
5. yarn >= 0.17.9

## 开发环境首次运行
1. 安装elixir包 `cd ~/phoenix_china_umbrella && mix deps.get`
2. 创建数据库并创建表，在当前目录下 `mix ecto.create && mix ecto.migrate`
3. 如有预装数据 `mix run apps/phoenix_china/priv/repo/seeds.exs`
4. 安装前端依赖 `cd ~/phoenix_china_umbrella/apps/phoenix_china_web/assets && yarn install`

## 开发环境
1. `cd ~/phoenix_china_umbrella && mix phx.server`


## Docker 环境运行
```bash
docker-compose up -d phoenix_china_umbrella
docker-compose run phoenix_china_umbrella mix ecto.create
docker-compose run phoenix_china_umbrella mix ecto.migrate
docker-compose run phoenix_china_umbrella mix run apps/phoenix_china/priv/repo/seeds.exs
docker-compose restart phoenix_china_umbrella
```

## 项目结构说明
* `apps/phoenix_china` 数据库
* `apps/phoenix_china_web` 网页
* `apps/phoenix_china_dashboard`(暂时没有) 管理后台
* `apps/phoenix_china_graphql`(暂时没有) GraphQL接口

## 代码贡献
* 请首先查阅TODO列表
* 发现BUG请提issue
* 请保证新增的代码都有测试
* 如有问题请随时在论坛或者qq群联系

## TODO
* [ ] 用户相关
  * [x] 用户注册
  * [x] 用户登录
  * [x] 用户退出登录
  * [ ] 邮箱验证
  * [ ] github登录
  * [ ] 个人主页
  * [ ] 个人资料修改
  * [ ] 修改密码
  * [ ] 找回密码
  * [ ] 用户关注
* [ ] 帖子相关
  * [ ] 发帖
  * [ ] 可以在帖子中@用户
  * [ ] 编辑帖子
  * [ ] 关闭帖子(帖子关闭之后不再接受任何回复，允许再次打开)
  * [ ] 关注帖子(关注后会对用户推送帖子动态)
  * [ ] 收藏帖子(帖子出现在个人主页的收藏面板中)
  * [ ] 点赞帖子(奖励积分)
  * [ ] 置顶帖子
* [ ] 帖子评论相关
  * [ ] 创建评论(不可编辑)
  * [ ] 删除评论
  * [ ] 点赞评论(奖励积分，并高亮优秀评论)
  * [ ] 回复评论(@功能)
* [ ] 通知系统(接受 用户关注、关注的用户发帖和评论、关注的帖子有回帖、发布的帖子被置顶、被其他用户@ 等消息)
  * [ ] 通知阅读
  * [ ] 通知单条删除和全部删除
* [ ] 后台系统
  * [ ] 管理用户
  * [ ] 管理帖子
  * [ ] 管理评论
* [ ] GraphQL接口
* [ ] Build & CI
  * [x] Travis
  * [x] Docker