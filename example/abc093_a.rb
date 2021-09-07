require "../bf.rb"

bm = BrainMem.new(true)

bm.exec do

  a = alloc
  b = alloc
  c = alloc
  tmp = alloc
  chr = alloc

  3.times do
    chr.getchar

    tmp.eq chr, ?a
    tmp.if_nonzero do
      a.add 1
    end

    tmp.eq chr, ?b
    tmp.if_nonzero do
      b.add 1
    end

    tmp.eq chr, ?c
    tmp.if_nonzero do
      c.add 1
    end
  end

  tmp.set 1
  tmp.mul a
  tmp.mul b
  tmp.mul c
  tmp.if_nonzero do
    puts "Yes"
  end
  tmp.if_zero do
    puts "No"
  end
end

# 実行
bm.bf.run_dump

# コード生成
puts bm.bf.to_s
