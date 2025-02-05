import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/colors/colors.dart';
import 'package:vvibe/common/values/enum.dart';
import 'package:vvibe/services/event_bus.dart';
import 'package:vvibe/utils/updater.dart';

class Updater extends StatefulWidget {
  Updater({Key? key, required this.child}) : super(key: key);
  Widget child;
  @override
  _UpdaterState createState() => _UpdaterState();
}

class _UpdaterState extends State<Updater> {
  UpdatStatus status = UpdatStatus.idle;
  Map<String, dynamic> info = {};
  @override
  void initState() {
    super.initState();

    //checkForUpdate();
    eventBus.on('check-for-update', (e) {
      checkForUpdate(true);
    });
  }

  checkForUpdate([bool showLoading = false]) async {
    EasyLoading.dismiss();
    if (showLoading) {
      EasyLoading.show(status: '正在检查更新！');
    }
    UpdaterUtil.initDownloadDir();
    setState(() {
      status = UpdatStatus.checking;
    });
    final _info = await UpdaterUtil.checkForUpdate();
    if (_info == null) {
      setState(() {
        status = UpdatStatus.error;
      });
      if (showLoading) {
        EasyLoading.showError('检查更新失败');
      }
      return;
    }
    if (mounted) {
      setState(() {
        status =
            _info['available'] ? UpdatStatus.available : UpdatStatus.upToDate;
        info = _info;
      });
    }
    print('need update $status');

    EasyLoading.dismiss();
    if (status == UpdatStatus.upToDate) {
      UpdaterUtil.clearDownloaDir();
    }
  }

  dismissUpdate() {
    setState(() {
      status = UpdatStatus.idle;
    });
  }

  startUpdate() async {
    setState(() {
      status = UpdatStatus.downloading;
    });
    final st = await UpdaterUtil.startDownload(info['latest']);
    setState(() {
      status = st != null ? st : UpdatStatus.error;
    });
  }

  startInstallUpdate() async {
    setState(() {
      status = UpdatStatus.idle;
    });
    UpdaterUtil.startInstallUpdate();
  }

  String get text {
    switch (status) {
      case UpdatStatus.available:
        return '发现新版本: ${info['latest'] ?? ''}';
      case UpdatStatus.readyToInstall:
        return '更新已下载';
      default:
        return '';
    }
  }

  String get cancelTooltip {
    switch (status) {
      case UpdatStatus.available:
        return '取消升级';
      case UpdatStatus.readyToInstall:
        return '取消安装';
      default:
        return '';
    }
  }

  String get confirmTooltip {
    switch (status) {
      case UpdatStatus.available:
        return '立即升级';
      case UpdatStatus.readyToInstall:
        return '立即安装';
      default:
        return '';
    }
  }

  Function get cancelCb {
    switch (status) {
      case UpdatStatus.available:
      case UpdatStatus.readyToInstall:
        return dismissUpdate;
      default:
        return () {};
    }
  }

  Function get confirmCb {
    switch (status) {
      case UpdatStatus.available:
        return startInstallUpdate;
      case UpdatStatus.readyToInstall:
        return startInstallUpdate;
      default:
        return () {};
    }
  }

  bool get showChip {
    switch (status) {
      case UpdatStatus.available:
      case UpdatStatus.readyToInstall:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
            bottom: 10,
            right: 10,
            child: Opacity(
              opacity: showChip ? 1 : 0,
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    deleteButtonTooltipMessage: cancelTooltip,
                    onDeleted: () {
                      cancelCb();
                    },
                  ),
                  Tooltip(
                      message: confirmTooltip,
                      child: IconButton(
                        color: AppColors.primaryColor,
                        icon: Icon(Icons.check, color: AppColors.primaryColor),
                        onPressed: () {
                          confirmCb();
                        },
                      )),
                ],
              ),
            ))
      ],
    );
  }
}
