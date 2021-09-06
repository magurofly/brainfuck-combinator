require "../bf.rb"
b = BrainMem.new

# メモリを確保
x = b.alloc(5)

# "hello" を代入
x.setstr "hello"

b.putstr x

# コードの生成
puts b.bf.to_s

# 実行（デバッグ）
b.bf.run_dump
