# brainfuck-combinator

Rubyでいろんなメソッドを呼ぶと、Brainfuckのコードを出力します

## 使い方

```bash
$ irb -r ./bf.rb
irb> b = BrainMem.new(false) # trueだと詳細な出力
irb> # コードを書く
irb> puts b.bf.to_s # Brainfuckコードを出力
```

### 制約

`BrainMem#bf << code` で直接Brainfuckコードを追加できますが、このコードを実行した後に`BrainMem#pointer`が正しいポインタの位置を指しているようにしてください。

## 機能

### メモリ

* `x = b.alloc(size = 1)`: 連続したメモリを確保、ポインタを返す
* `x.free`: メモリを解放（※freeする前に0にしないと壊れるかも）
* `b.alloc_tmp { |ptr| ... }`: 一時的にメモリを確保
* `b.go_to x`: `x`がある位置にBrainfuckのポインタを移動させる
* `b.zero(dst)`: dstを0にする
* `b.move(dst, src)`: srcをdstに移動する（srcは0になる）
* `b.copy(dst, src)`: srcをdstにコピーする
* `x.set(y)`: xにyを代入する

### 算術演算
* `x.add(y)`: 8ビット符号なし整数の加算（yはポインタか値）
* `x.sub(y)`: 8ビット符号なし整数の減算（yはポインタか値）
* `x.mul(y)`: 8ビット符号なし整数の乗算（yはポインタか値）

### 論理演算
* `x.not`

### 比較演算
* `x.eq(y, z)`: `y == z`の結果を`x`に格納
* `x.ne(y, z)`: `y != z`の結果を`x`に格納
* `x.lt(y, z)`: `y < z`の結果を`x`に格納
* `x.le(y, z)`: `y <= z`の結果を`x`に格納
* `x.gt(y, z)`: `y > z`の結果を`x`に格納
* `x.ge(y, z)`: `y >= z`の結果を`x`に格納

### 制御
* `x.times { ... }`: `x`の回数だけ繰り返す
* `x.if_nonzero { ... }`: `x`が0でなければ実行
* `x.if_zero { ... }`: `x`が0なら実行
* `x.while_nonzero { ... }`: `x`が0でない間繰り返す
* `x.while_zero { ... }`: `x`が0の間繰り返す

## バグ

なんか比較系の演算をするときにどこかのメモリがずれてるらしい　涙

## 使用例

- [https://github.com/magurofly/brainfuck-combinator/tree/main/example]

```ABC038A.rb
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
```
