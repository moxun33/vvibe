import 'package:flutter/material.dart';
import 'package:vvibe/common/colors/colors.dart';
import 'package:vvibe/common/values/enum.dart';
import 'package:vvibe/utils/playlist/playlist_util.dart';
import 'package:vvibe/utils/updater.dart';
import 'package:window_manager/window_manager.dart';

class UpdaterWidgets {
  static Widget updateChipBuilder({
    required BuildContext context,
    required String? latestVersion,
    required String appVersion,
    required UpdatStatus status,
    required void Function() checkForUpdate,
    required void Function() openDialog,
    required void Function() startUpdate,
    required Future<void> Function() launchInstaller,
    required void Function() dismissUpdate,
  }) {
    if (status == UpdatStatus.available ||
        status == UpdatStatus.availableWithChangelog) {
      return Row(
        children: [
          Chip(
            label: Text(
              '发现新版本: $latestVersion',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            deleteButtonTooltipMessage: '取消升级',
            onDeleted: () {
              dismissUpdate();
            },
          ),
          Tooltip(
              message: '立即升级',
              child: IconButton(
                color: AppColors.primaryColor,
                icon: Icon(Icons.check, color: AppColors.primaryColor),
                onPressed: () {
                  startUpdate();
                },
              )),
        ],
      );
    }
    if (status == UpdatStatus.readyToInstall) {
      return Row(children: [
        Chip(
          label: Text(
            '新版本: $latestVersion 已就绪',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          deleteButtonTooltipMessage: '取消安装',
          onDeleted: () {
            dismissUpdate();
          },
        ),
        Tooltip(
            message: '立即安装',
            child: IconButton(
              color: AppColors.primaryColor,
              icon: Icon(Icons.check, color: AppColors.primaryColor),
              onPressed: () {
                launchInstaller();
              },
            ))
      ]);
    }
    if (status == UpdatStatus.error) {
      return Chip(
        label: Text(
          '自动升级 $latestVersion  失败',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        deleteButtonTooltipMessage: '手动升级',
        deleteIcon: Icon(Icons.download_for_offline_outlined),
        onDeleted: () {
          dismissUpdate();
          PlaylistUtil().openAppExecSubDir(UpdaterUtil.downloadDir);
          windowManager.close();
        },
      );
    }

    return SizedBox();
  }

  static updateDialogBuilder({
    required BuildContext context,
    required String? latestVersion,
    required String appVersion,
    required UpdatStatus status,
    required String? changelog,
    required void Function() checkForUpdate,
    required void Function() openDialog,
    required void Function() startUpdate,
    required Future<void> Function() launchInstaller,
    required void Function() dismissUpdate,
  }) {
    openDialog();
  }
}
