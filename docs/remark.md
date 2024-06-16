 # 备注

 ## 获取``pubspec.yaml``的version
 ```bash
 cat pubspec.yaml | grep 'version:' | head -1 | cut -f2- -d: | sed -e 's/^[ \t]*//'
```

## 提升版本号
```bash
awk '{ match($0,/([0-9]+)\+([0-9]+)/,a); a[1]=a[1]+1; a[2]=a[2]+1; sub(/[0-9]+\+[0-9]+/,a[1]"+"a[2])}1' pubspec.yaml | grep 'version:' | head -1 | cut -f2- -d: | sed -e 's/^[ \t]*//'
```

## 更新``pubspec.yaml``的version
```bash
awk '{ match($0,/([0-9]+)\+([0-9]+)/,a); a[1]=a[1]+1; a[2]=a[2]+1; sub(/[0-9]+\+[0-9]+/,a[1]"+"a[2])}1' pubspec.yaml | grep 'version:' | head -1 | cut -f2- -d: | sed -e 's/^[ \t]*//'
```