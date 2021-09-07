require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  t = alloc
  c = alloc
  d = alloc
  S = alloc(30)

  c.getchar
  t.getchar
  S.gets

  d.set 255

  26.times do |i|
    alloc_tmps(2) do |tmp1, tmp2|
      tmp1.lt c, S[i]
      tmp2.gt d, S[i]
      tmp1.mul tmp2
      tmp1.if_nonzero do
        d.copy S[i]
      end
    end
  end

  d.putchar
end

# 実行
# bm.bf.make.dump_run(0.1)
bm.bf.run_dump

# # コード生成
puts bm.bf.to_s