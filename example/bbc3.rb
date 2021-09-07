require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  n = alloc(10)
  n.gets
  s = alloc(120)
  s.gets
  s.puts
end

# 実行
# bm.bf.make.dump_run(0.1)
bm.bf.run_dump

# # コード生成
puts bm.bf.to_s