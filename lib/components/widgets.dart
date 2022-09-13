/*
 * @Author: moxun33
 * @Date: 2022-09-13 21:40:49
 * @LastEditors: moxun33
 * @LastEditTime: 2022-09-13 21:40:53
 * @FilePath: \vvibe\lib\components\widgets.dart
 * @Description: 一些小组件
 * @qmj
 */
/* 
菜单定义
final List<Map<String, dynamic>> _urlCtxMenus = [
    {'value': 'copy', 'label': '复制链接', 'icon': Icons.copy_all_outlined},
  ];
 */
//右键菜单列表
import 'package:flutter/material.dart';

class ContextMenus extends StatelessWidget {
  const ContextMenus(
      {Key? key,
      required this.menuItems,
      required this.onItemTap,
      this.listSize = const Size(140, 210)})
      : super(key: key);
  final List<Map<String, dynamic>> menuItems;
  final Size listSize;
  final void Function(BuildContext context, Map<String, dynamic> item)
      onItemTap;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            width: listSize.width,
            height: listSize.height,
            color: Colors.white,
            child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(5),
                itemCount: menuItems.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = menuItems[index];
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      child: SizedBox(
                          width: 130,
                          height: 40,
                          child: Row(
                            children: [
                              Icon(
                                item['icon'],
                                color: Colors.purple,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                item['label'] ?? '',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                              ),
                            ],
                          )),
                      onPressed: () {
                        onItemTap(
                          context,
                          item,
                        );
                      },
                    ),
                  );
                })));
  }
}
