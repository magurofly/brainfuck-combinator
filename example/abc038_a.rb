require "../bf.rb"

bm = BrainMem.new(true)

EOF = 255

bm.exec do

  cur = alloc
  prev = alloc
  cont1 = alloc
  cont2 = alloc

  get = -> {
    prev.copy cur
    cur.getchar
    cont1.eq cur, EOF
    cont2.eq cur, ?\n
    cont1.add cont2
  }

  get[]
  cont1.while_zero do
    get[]
  end

  cont1.eq prev, ?T
  cont1.if_nonzero do
    print "YES"
  end
  cont1.if_zero do
    print "NO"
  end
end

# 実行
bm.bf.run_dump

# コード生成
puts bm.bf.to_s
