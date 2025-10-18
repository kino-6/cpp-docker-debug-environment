// エラー出力解析とProblemパネル連携のテスト用ファイル
// このファイルは意図的にエラーを含んでいます

#include <iostream>
#include <vector>
#include "non_existent_header.h"  // エラー: 存在しないヘッダファイル

int main() {
    // エラー: 未定義の変数
    std::cout << undefined_variable << std::endl;
    
    // エラー: 型の不一致
    int number = "string";
    
    // エラー: セミコロン忘れ
    std::vector<int> vec
    
    // 警告: 未使用変数
    int unused_var = 42;
    
    // エラー: 存在しない関数呼び出し
    non_existent_function();
    
    // エラー: return文忘れ（int main()なので）
}

// エラー: 関数の重複定義
void test_function() {
    std::cout << "First definition" << std::endl;
}

void test_function() {
    std::cout << "Second definition" << std::endl;
}