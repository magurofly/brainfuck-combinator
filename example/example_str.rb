require "../bf.rb"
b = BrainMem.new

# メモリを確保
x = b.alloc(5)

# "hello" を代入
"hello".each_char.with_index do |c, i|
  x[i].set c
end

# 出力
b.putstr x

# コードの生成
puts b.bf.to_s

# 実行（デバッグ）
b.bf.run_dump
