require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  t = alloc
  a = alloc
  b = alloc
  
  a.getdigit
  t.getchar
  b.getdigit
  
  t.zero
  t.lt a, b
  t.if_nonzero do
    print "Y"
  end
  t.if_zero do
    print "N"
  end
end

# 実行
# bm.bf.make.dump_run(0.1)
bm.bf.run_dump

# # コード生成
puts bm.bf.to_s