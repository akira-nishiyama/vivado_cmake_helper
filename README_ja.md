# 概要

このスクリプトはvivadoとvivado_hlsをcmakeでビルドするためのヘルパースクリプトです。
スクリプトは以下の２つのcmake packageを含んでいます。
- vivado_cmake_helper: vivado ip export用です。
- vivado_hls_cmake_helper: vivado_hls の ip export用です。

# テストした環境
Ubuntu 18.04
Vivado 2019.2  
Vivado_HLS 2019.2  
CMake 3.10.2  

# 使用例
[ICS_IF](https://github.com/akira-nishiyama/ICS_IF)を参考にしてください。また、CMakeLists.txtの例もexampleフォルダに格納しています。

# 事前準備
VIVADO_CMAKE_HELPER環境変数にリポジトリパスを登録します。(またはcmake実行時に-Dvivado_cmake_helper_DIR/-Dvivado_hls_cmake_helper_DIR=\<path_to_repository\> オプションで指定してください)
次のスクリプトを動かしてください。
```bash
source <path-to-repository>/setup.sh
```

# 使い方
## vivado_hls
### ディレクトリ構造
サンプルは以下に示すディレクトリ構造を想定しています。
```
project_top
├── CMakeLists.txt:リポジトリ同梱のCMakeLists.txt.hls_example
├── directives.tcl
├── include:ヘッダ置き場
├── src:ソース置き場
└── test:テストベンチ置き場
    ├── include:テストベンチ用ヘッダ置き場
    └── src:テストベンチ用ソース置き場
```

### CMakeLists.txtの編集方法
使い方の例は example/CMakeLists.txt.hls_exaqmpleを参考にしてください。
find_packageで vivado_hls_cmake_helperを見つけてください。
CTestを使用する場合はenable_testing()で有効にしてください。
このスクリプトはPROJECT_NAMEはtop_functionと同じであることを仮定しています。またPROJECT_NAMEはビルドターゲットの名前としても使用されます。
ヘッダの保存パスをCFLAGS及びCFLAGS_TESTBENCHにリストとして追加してください。  
ソースをSRC_FILESやTESTBENCH_FILESにリストとして追加してください。  
リストは区切りの";"を":"に置き換えてください。(そうしないと誤動作する)  
その後vivado_hls_export.cmakeをインポートしてください。  
これはビルドに必要なcustom_commandとcustom_targetを追加します.  
また、csimulation用のadd_testターゲットを追加します。
加えて、インストール設定も追加します。archive zipファイルを除き生成結果のipフォルダーをCMAKE_INSTALL_PREFIX/${project_name}にコピーします。  

### インストール
インストールは以下コマンドで実行できます。<>でくくった部分は環境に合わせて設定してください。

```{class="prettyprint lang=sh"}
source <path_to_vivado>/setup.sh
source <path_to_this_repository>/setup.sh
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=<path_to_user_ip_repository>
cmake --build .
make install
```

### Test
ctestを実行するだけで動作します。
```bash
ctest
```

## vivado ip packager(ipx)
### ディレクトリ構造
サンプルは以下に示すディレクトリ構造を想定しています。
```
project_top
├── CMakeLists.txt:リポジトリ同梱のCMakeLists.txt.ipx_example
├── scripts:blockdesign.tclが保存されることを期待
├── src:rtlモジュール置き場
└── test:テストベンチ置き場
    └── src:テストベンチ用ソース置き場
```

### CMakeLists.txtの編集方法
使い方の例は example/CMakeLists.txt.ipx_exaqmpleを参考にしてください。
blockdesign.tclはvivadoのwrite_bd_tclコマンドを使用して作成してください。  
design_nameとCMakeLists.txtの編集方法project_nameが同じになるようにしてください。  
(または生成されたblockdesign.tclを修正してdesign_nameを変更してください)  
find_package()でvivado_cmake_helperパッケージを検索してください。
また、CTestを使用する場合はenable_testing()を有効にしてください。
必要に応じてrtl moduleとtestbenchをそれぞれSRC_FILES、TESTBENCH_FILESに追加してください。  
IPを出力する場合には以下の関数を実行してください。(これらはvivado_ipx_export.cmakeで定義されます。)

+ project_generation(PROJECT_NAME VENDOR LIBRARY_NAME TARGET_DEVICE SRC_FILES TESTBENCH_FILES IP_REPO_PATH)
  prj_gen_\${PROJECT_NAME}ターゲットを追加します。
  これはvivadoプロジェクトの生成に使用します。(このヘルパースクリプトはコンパイル順やインクルードライブラリ、IP出力にvivadoプロジェクトを使用します。)
  + arg0:出力IP名(プロジェクト名を想定)
  + arg1:ベンダ名
  + arg2:ライブラリ名(user以外は試していません)
  + arg3:ターゲットデバイス
  + arg4:ソースファイルのリスト。リスト渡しなので、"で囲んでください。
  + arg5:シミュレーションファイルリスト。同上
  + arg6:IPリポジトリのパスリスト。同上。
+ project_add_bd(BLOCK_NAME BLOCK_DESIGN_TCL DEPENDENCIES)
  block_designを使用する場合に使用してください。
  この関数はvivadoプロジェクトにblock_designを追加します。(他のtclコードを使用してプロジェクトを操作できるかもしれませんが試していません)
  実行するとadd_bd_\${BLOCK_NAME}ターゲットを追加します。
  + arg0:\${BLOCK_NAME}はターゲット名として使用されます。
  + arg1:block design追加用のtclパスを指定してください。block design追加用のスクリプトはvivadoのwrite_bd_tclを使用して作成してください。
  + arg2:add_bd_\${BLOCK_NAME}ターゲットの依存ファイルや依存ターゲットをリストで指定してください。リスト渡しなので、"で囲んでください。
+ export_ip(VENDOR LIBRARY_NAME RTL_PACKAGE_FLAG)
  add_custom_targetで\${PROJECT_NAME}ターゲットを追加します。また同時にビルド用にALLターゲットにも追加します.
  exportするターゲット名(blockdesignの名前やrtl のモジュール名)はproject_nameと同じである必要があります。
  また、インストール設定も同時に行います。archive zipファイルを除き生成結果のipフォルダーをCMAKE_INSTALL_PREFIX/${project_name}にコピーします。
  + arg0:ベンダ名.
  + arg1:ライブラリ名(user以外は試していません)
  + arg2:rtlパッケージフラグ. 0はblock_design ip 出力モードで、1がrtlモジュールのip出力モードです.

シミュレーション設定をする場合はadd_sim関数を使用してください。
+ add_sim(SIM_TARGET SIMULATION_DIR DEPENDENCIES ADDITIONAL_VLOG_OPTS ADDITIONAL_ELAB_OPTS ADDITIONAL_XSIM_OPTS PREV_TARGET)
  以下のcustom_targetを追加します。  [gen_\${SIM_TARGET},compile_\${SIM_TARGET},elaborate_\${SIM_TARGET},simulate_\${SIM_TARGET},open_wdb_\${SIM_TARGET}]
  また、compile_all, elaborate_all及びsimulate_allターゲットにも追加します。
  加えてCTest用の設定も行います。simulate_\${SIM_TARGET}.ctestがテスト名として追加されます。
  CTestはUVM_FATALやUVM_ERRORメッセージが出力されると失敗するようになっています。
  + arg0:シミュレーションターゲット用のモジュール名。
  + arg1:シミュレーション用ワークスペース。
  + arg2:シミュレーションの依存ファイルをリストで記載してください。リスト渡しなので、"で囲んでください。
  + arg3:verilogコンパイル用の追加オプションを記載してください。ユーザインクルードディレクトリなどを追加してください。
  + arg4:追加のelaborateオプションを指定してください。
  + arg5:追加のxsimオプションを指定してください。必要な場合はUVM_TESTNAMEの設定などを行ってください。
  + arg6:コンパイル順を指定するために使用します。(vivadoで複数のコンパイルターゲットが走るとエラーになってしまうため。以下のようにシングルプロセスでビルド実行する場合には指定しなくとも問題ないです。)

```bash
make -j4 && make compile_all -j1 && make_elaborate_all -j4 && ctest -j4
```  

### インストール
インストールは以下コマンドで実行できます。<>でくくった部分は環境に合わせて設定してください。

```{class="prettyprint lang=sh"}
source <path_to_vivado>/setup.sh
source <path_to_this_repository>/setup.sh
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=<path_to_user_ip_repository>
cmake --build .
make install
```

### Test
buildディレクトリでelaborate_allターゲットを実行した後にctestを実行してください。並列実行数の指定も可能です。
```bash
make elaborate_all
ctest -j4
```

### 波形表示
ビルドディレクトリでopen_wdb_\${SIM_TARGET}ターゲットを実行してください。
```bash
make open_wdb_\${SIM_TARGET}
```

## プロジェクトのネスト
プロジェクトがネストしていても動作します。[ICS_IF](#https://github.com/akira-nishiyama/ICS_IF)に例があります。  
add_subdirectory(modules)で追加し、各々ビルドできるようにCMakeLists.txtを作成してください。

# License
This software is released under the MIT License, see LICENSE.
