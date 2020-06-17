## 0.3.17 (Unreleased)
## 0.3.16 (June 18, 2020)

IMPROVEMENTS:
- [Enhance tests][Files & Directory scenarios] Test get nested directories and files in nested directory [GH-98](https://github.com/fog/fog-aliyun/pull/98)
- remove get_bucket_location and use ruby sdk to improve performance when uploading object [GH-97](https://github.com/fog/fog-aliyun/pull/97)
- using bucket_exist to checking bucket [GH-95](https://github.com/fog/fog-aliyun/pull/95)
- add change log [GH-94](https://github.com/fog/fog-aliyun/pull/94)

BUG FIXES:
- fix delete all of files bug when specifying a prefix [GH-102](https://github.com/fog/fog-aliyun/pull/102)

## 0.3.15 (June 05, 2020)

BUG FIXES:
- change dependence ruby sdk to gems [GH-92](https://github.com/fog/fog-aliyun/pull/92)

## 0.3.13 (June 02, 2020)

IMPROVEMENTS:
- using ruby sdk to delete object [GH-90](https://github.com/fog/fog-aliyun/pull/90)

## 0.3.12 (May 28, 2020 )

BUG FIXES:
- add missing dependence [GH-88](https://github.com/fog/fog-aliyun/pull/88)

## 0.3.11 (May 25, 2020)

IMPROVEMENTS:
- using oss ruby sdk to improve downloading object performance [GH-86](https://github.com/fog/fog-aliyun/pull/86)
- Add performance tests [GH-85](https://github.com/fog/fog-aliyun/pull/85)
- [Enhance tests][Entity operations]Add tests for each type of entity that validates the CURD operations [GH-84](https://github.com/fog/fog-aliyun/pull/84)
- [Enhance tests][Auth & Connectivity scenarios] Test region is selected according to provider configuration [GH-83](https://github.com/fog/fog-aliyun/pull/83)
- [Enhance tests][Files & Directory scenarios] test file listing using parameters such as prefix, marker, delimeter and maxKeys [GH-82](https://github.com/fog/fog-aliyun/pull/82)
- [Enhance tests][Files & Directory scenarios]test directory listing using parameters such as prefix, marker, delimeter and maxKeys [GH-81](https://github.com/fog/fog-aliyun/pull/81)
- [Enhance tests][Files & Directory scenarios]Test that it is possible to upload (write) large file (multi part upload) [GH-79](https://github.com/fog/fog-aliyun/pull/79)
- upgrade deprecated code [GH-78](https://github.com/fog/fog-aliyun/pull/78)
- improve fog/integration_spec [GH-77](https://github.com/fog/fog-aliyun/pull/77)
- [Enhance tests][Files & Directory scenarios]Test that it is possible to upload (write) a file [GH-76](https://github.com/fog/fog-aliyun/pull/76)
- upgrade deprecated code [GH-74](https://github.com/fog/fog-aliyun/pull/74)
- support https scheme [GH-71](https://github.com/fog/fog-aliyun/pull/71)
- [Enhance tests][Files & Directory scenarios]Test that it is possible to destroy a file/directory [GH-69](https://github.com/fog/fog-aliyun/pull/69)
- improve fog/integration_spec [GH-68](https://github.com/fog/fog-aliyun/pull/68)
- Implement basic integration tests [GH-66](https://github.com/fog/fog-aliyun/pull/66)

## 0.3.10 (May 07, 2020)

IMPROVEMENTS:
- Set max limitation to 1000 when get objects [GH-64](https://github.com/fog/fog-aliyun/pull/64)

## 0.3.9 (May 07, 2020)

BUG FIXES:
- diectories.get supports options to filter the specified objects [GH-62](https://github.com/fog/fog-aliyun/pull/62)