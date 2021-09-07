# coding: UTF-8

require "stringio"

class Brainfuck
  MEM = 10000
  DEFAULT_LIMIT = 100000

  attr_accessor :program, :indent

  def initialize
    @program = ""
    @indent = 0
    @newline = true
  end

  def to_s
    @program
  end

  def <<(str)
    @newline = false
    @program << str
  end

  def make(input = STDIN)
    input = StringIO.new(input) if input.is_a? String
    Env.new(@program, input)
  end

  def run(input = STDIN, count = DEFAULT_LIMIT)
    env = make(input)
    env.run(count)
    env.output
  end

  def run_dump(input = STDIN, count = DEFAULT_LIMIT)
    env = make(input)
    env.run(count)
    env.dump
    env.output
  end

  def newline
    self << ?\n << "  " * @indent
    @newline = true
  end

  def comment(text = "")
    newline unless @newline
    self << "# " << escape(text)
    newline
  end

  def escape(text)
    text.gsub(/\+/, '＋').gsub(/-/, 'ー').gsub(/</, '＜').gsub(/>/, '＞').gsub(/\[/, '［').gsub(/\]/, '］').gsub(/\./, '．').gsub(/,/, '，')
  end

  def clear
    @program = ""
  end

  # 以下、util

  # -- 計算 --

  # mem[ptr] = 0
  def zero
    self << "[-]"

    return
  end

  # mem[ptr].times { mem[ptr] -= 1; yield }
  def repeat
    self << "[-"
    yield
    self << "]"

    return
  end

  class Env
  
    attr_accessor :program, :pc, :input, :read, :mem, :ptr, :output
  
    def initialize(program, input)
      @program = program
      @pc = 0
      @input = input
      @read = ""
      @mem = [0] * MEM
      @pointer = 0
      @pointer_max = 0
      @output = ""
      @step = 0
    end
  
    def run(count = DEFAULT_LIMIT)
      while @step < count
        break unless step
      end
  
      if @step >= count
        STDERR.puts "Brainfuck: program steps exceeded #{count}"
      end
    end
  
    def step
      return false if @pc >= @program.size
      @step += 1
      case @program[@pc]
      when ?+
        @mem[@pointer] += 1
        @mem[@pointer] %= 256
        @pc += 1
      when ?-
        @mem[@pointer] -= 1
        @mem[@pointer] %= 256
        @pc += 1
      when ?<
        raise "Brainfuck: negative pointer" if @pointer <= 0
        @pointer -= 1
        @pc += 1
      when ?>
        raise "Brainfuck: memory limit exceeded" if @pointer >= MEM
        @pointer += 1
        @pointer_max = @pointer if @pointer_max < @pointer
        @pc += 1
      when ?.
        @output << @mem[@pointer].chr
        @pc += 1
      when ?,
        # if @read < @input.size
        #   @mem[@pointer] = @input[@read].ord
        #   @read += 1
        # else
        #   @mem[@pointer] = 255
        # end
        if @input.eof?
          @mem[@pointer] = 255
        else
          c = @input.read(1)
          @read << c
          @mem[@pointer] = c.ord
        end
        @pc += 1
      when ?[
        if @mem[@pointer] == 0
          depth = 1
          index = @pc
          while depth > 0 and index + 1 < @program.size
            index += 1
            case @program[index]
            when ?[
              depth += 1
            when ?]
              depth -= 1
            end
          end
          raise "Brainfuck: expected ]" if depth > 0
          @pc = index
        end
        @pc += 1
      when ?]
        if @mem[@pointer] != 0
          depth = -1
          index = @pc
          while depth < 0 and index > 0
            index -= 1
            case @program[index]
            when ?[
              depth += 1
            when ?]
              depth -= 1
            end
          end
          if depth == 0
            @pc = index
          else
            # 対応するカッコがなければ先頭へ
            @pc = -1
          end
        end
        @pc += 1
      else
        @pc += 1
      end
      true
    end
  
    def dump(out = STDERR)
      program = "\e[m#{@program[0, @pc]}\e[31m@\e[m#{@program[@pc..-1]}".lines.join("          \e[31m|\e[m")
      input = "\e[m#{@read}".lines.join("          \e[31m|\e[m")
      output = @output
      # output = output.gsub(/[\x00-\x19\x7f-\xff]/) { |c| "\e[32m\\x%02x\e[m" % c.ord }
      output = output.lines.join("          \e[31m|\e[m")
      out.puts <<-EOT
program:  \e[31m{#{program}\e[31m}\e[m
input:    \e[31m{#{input}\e[31m}\e[m
output:   \e[31m{\e[m#{output}\e[31m}\e[m
info:
  step = #{@step}, memory = #{@pointer_max + 1}, length = #{@program.size}
memory:
      EOT
      memory_rows = (0 ... (@pointer_max + 1 + 15) / 16).map { |i| ["    %02X: " % (i * 16), @mem[i * 16, 16].map { |d| "%02X" % d }] }
      memrow = memory_rows[@pointer / 16][1]
      memrow[@pointer % 16] = "\e[44;37m" + memrow[@pointer % 16]
      memrow[@pointer % 16] += "\e[m"
      out.puts memory_rows.map { |prefix, mem| prefix + mem.join(" ") }
    end
  
    def dump_run(wait = STDIN, out = STDERR, interval = 0.1)
      out.puts "Enter to stop"
      running = true
      t = Thread.fork do
        while running
          break unless step
          dump
          sleep interval if interval
        end
      end
      wait.gets
      running = false
      dump
    end
  end
end

class BrainMem
  attr_reader :bf, :pointer, :mem
  def initialize(verbose = false)
    @bf = Brainfuck.new
    @mem = [true] * 10000
    @pointer = 0
    @verbose = verbose
  end

  def inspect
    "#<BrainMem:0x%016x @pointer=%d @mem.used=%d>" % [object_id * 2, @pointer, @mem.count(false)]
  end

  def exec(&block)
    self.instance_exec(&block)
  end

  class Ptr
    attr_reader :ptr, :size
    def initialize(ptr, size, bm = nil)
      @ptr, @size, @bm = ptr, size, bm
    end

    def to_s
      if @size != 1
        "$(#{@ptr}:#{@size})"
      else
        "$#{@ptr}"
      end
    end

    def inspect
      to_s
    end

    def free
      @bm.free(self)
    end

    def [](i, len = 1)
      case i
      when Integer
        raise "Brainfuck: index out of range" unless (0 ... @size) === i
        Ptr.new(@ptr + i, len, @bm)
      end
    end

    def move_to(dst)
      @bm.move(dst, self)
    end

    def copy_to(dst, tmp = nil)
      @bm.copy(dst, self, tmp)
    end

    (
      %i(move copy zero set) +
      %i(getchar getdigit putchar putdigit putstr getstr setstr) +
      %i(add sub) +
      %i(eq) +
      %i(not) +
      %i(if_zero if_nonzero while_zero while_nonzero times)
    ).each do |name|
      define_method(name, & ->(*args, &block) {
        @bm.method(name).call(self, *args, &block)
      })
    end
  end

  # -- メモリ操作 --

  def alloc(size = 1, base = @pointer)
    ptr = find_nearest_free(size, base)
    raise "Brainfuck: failed to alloc" unless ptr
    # STDERR.puts "alloc #{ptr}:#{size}"
    size.times do |i|
      @mem[ptr + i] = false
    end
    Ptr.new(ptr, size, self)
  end

  def free(ptr)
    ptr, size = ptr.ptr, ptr.size
    # STDERR.puts "free #{ptr}:#{size}"
    # go_to ptr
    # _zero ptr
    size.times do |i|
      @mem[ptr + i] = true
    end
  end

  def find_nearest_free(size = 1, base = @pointer)
    i = base.upto(9999 - size + 1).find { |ptr| (0 ... size).all? { |offset| @mem[ptr + offset] } }
    if (i2 = (base - size + 1).downto(0).find { |ptr| (0 ... size).all? { |offset| @mem[ptr + offset] } })
      i = i2 if not i or (base - i).abs > (base - i2).abs
    end
    i
  end

  def alloc_tmp(size = 1, base = @pointer)
    ptr = alloc(size, base)
    ret = yield(ptr)
    free(ptr)
    ret
  end

  def alloc_tmps(count, size = 1, base = @pointer)
    ptrs = (0 ... count).map { alloc(size, base) }
    ret = yield(*ptrs)
    ptrs.each { |ptr| free(ptr) }
    ret
  end

  def go_tmp
    ptr = @pointer
    ret = yield
    go_to ptr
    ret
  end

  def go_by(delta)
    @pointer += delta
    if delta < 0
      @bf << ?< * -delta
    elsif delta > 0
      @bf << ?> * delta
    end
  end

  def go_to(to, offset = 0, from = @pointer)
    to = to.ptr if to.is_a? Ptr
    go_by(to - from + offset)
  end

  def move(dst, src)
    @bf.comment "#{dst} = move(#{src})" if @verbose
    _move(dst, src)
  end

  def _move(dst, src)
    go_to src
    @bf << ?[
      go_to dst
      @bf << ?+
      go_to src
      @bf << ?-
    @bf << ?]
  end

  def zero(dst)
    @bf.comment "#{dst} = 0" if @verbose
    _zero(dst)
  end

  def _zero(dst)
    go_to dst
    @bf << "[-]"
  end

  def copy(dst, src, tmp = nil)
    @bf.comment "#{dst} = #{src}" if @verbose
    _copy(dst, src, tmp)
  end

  def _copy(dst, src, tmp = nil)
    if dst.is_a? Ptr and dst.size > 1
      case src
      when Integer
        _set(dst[0], src)
        (dst.size - 1).times do |i|
          _copy(dst[i + 1], dst[i])
        end
      when String
        _copy dst, src.bytes, tmp
      when Array
        len = src.size
        _set dst[0], src[0]
        (dst.size - 1).times do |i|
          _copy dst[i + 1], dst[i]
          _add_const dst[i + 1], src[(i + 1) % len].ord - src[i % len].ord
        end
      when Ptr
        len = [len, dst.size, src.size].min
        len.times do |i|
          _copy dst[i], src[i]
        end
      end
      return
    end

    return alloc_tmp { |ptr| _copy(dst, src, ptr) } unless tmp
    _zero(dst)
    go_to src
    @bf << ?[
      go_to dst
      @bf << ?+
      go_to tmp
      @bf << ?+
      go_to src
      @bf << ?-
    @bf << ?]
    _move(src, tmp)
  end

  def _add_const(dst, src)
    if src < 0
      _addsub_const ?-, dst, -src
    else
      _addsub_const ?+, dst, src
    end
  end

  def set(dst, src, tmp = nil)
    case src
    when Integer
      @bf.comment "#{dst} = #{src}" if @verbose
      _add_const dst, src
    when String
      @bf.comment "#{dst} = #{src.inspect}.ord" if @verbose
      _add_const dst, src.ord
    when Ptr
      copy(dst, src, tmp)
    else
      raise "Brainfuck: undefined operation"
    end
  end

  # -- 計算 --

  def _set(dst, val)
    case val
    when Integer
      _zero dst
      if val > 0
        _addsub_const ?+, dst, val
      elsif val < 0
        _addsub_const ?-, dst, -val
      end
    when String
      # TODO: range set
      _set dst, val.ord
    when Ptr
      _copy dst, val
    else
      raise "Brainfuck: undefined operation"
    end
  end

  def _addsub_const(op, dst, val)
    n = 5
    if val >= n**2
      alloc_tmp do |tmp|
        _addsub_const(?+, tmp, val / n**2 * n)
        go_to tmp
        @bf.repeat do
          go_to dst
          _addsub_const(op, dst, n)
          go_to tmp
        end
      end
      val %= n**2
    end
    go_to dst
    @bf << op * val
  end

  def _add(dst, src, scale = 1)
    go_to src
    @bf << "[-"
      go_to dst
      @bf << ?+ * scale
      go_to src
    @bf << "]"
  end

  def _sub(dst, src, scale = 1)
    go_to src
    @bf << "[-"
      go_to dst
      @bf << ?- * scale
      go_to src
    @bf << "]"
  end

  def add!(dst, src)
    case src
    when Integer
      return sub!(dst, -src) if src < 0
      @bf.comment "#{dst} += #{src}" if @verbose
      _addsub_const ?+, dst, src
    when String
      @bf.comment "#{dst} += #{src.inspect}.ord" if @verbose
      _addsub_const ?+, dst, src.ord
    when Ptr
      @bf.comment "#{dst} += move(#{src})" if @verbose
      _add(dst, src)
    else
      raise "Brainfuck: undefined operation"
    end
  end

  def add(dst, src, tmp = nil)
    if src.is_a? Ptr
      return alloc_tmp { |ptr| add(dst, src, ptr) } unless tmp
      @bf.comment "#{dst} += #{src}" if @verbose
      _copy(tmp, src)
      _add(dst, tmp)
    else
      add!(dst, src)
    end
  end

  def sub!(dst, src)
    case src
    when Integer
      return add!(dst, -src) if src < 0
      @bf.comment "#{dst} -= #{src}" if @verbose
      _addsub_const ?-, dst, src
    when String
      @bf.comment "#{dst} -= #{src.inspect}.ord" if @verbose
      _addsub_const ?-, dst, src
    when Ptr
      @bf.comment "#{dst} -= move(#{src})" if @verbose
      _sub(dst, src)
    else
      raise "Brainfuck: undefined operation"
    end
  end

  def sub(dst, src, tmp = nil)
    if src.is_a? Ptr
      return alloc_tmp { |ptr| sub(dst, src, ptr) } unless tmp
      @bf.comment "#{dst} -= #{src}" if @verbose
      _copy(tmp, src)
      _sub(dst, tmp)
    else
      add!(dst, src)
    end
  end

  def _mul(dst, src)
    alloc_tmps(2) do |x, y|
      _move x, dst
      _times(src) do
        _copy y, x
        _add dst, y
      end
      _zero x
    end
  end

  def mul!(dst, src)
    case src
    when Integer
      @bf.comment "#{dst} *= #{src}" if @verbose
      alloc_tmp do |tmp|
        _move tmp, dst
        _add dst, tmp, src
      end
    when Ptr
      @bf.comment "#{dst} *= move(#{src})" if @verbose
      _mul(dst, src)
    else
      raise "Brainfuck: undefined operation"
    end
  end

  def mul(dst, src)
    if src.is_a? Ptr
      @bf.comment "#{dst} *= #{src}" if @verbose
      alloc_tmp do |tmp|
        _copy(tmp, src)
        _mul(dst, tmp)
      end
    else
      mul!(dst, src)
    end
  end

  # -- 比較 --

  def eq(dst, src_l, src_r)
    @bf.comment "#{dst} = #{src_l.inspect} == #{src_r.inspect}" if @verbose
    _eq(dst, src_l, src_r)
  end

  def _eq(dst, src_l, src_r)
    case src_r
    when Integer
      alloc_tmp { |tmp| _set tmp, src_r; _eq dst, src_l, tmp }
    when String
      _eq(dst, src_l, src_r.ord)
    when Ptr
      _zero dst
      if src_l.is_a? Integer
        _set dst, src_l
      else
        _copy dst, src_l
      end
      _sub dst, src_r
      self.not dst, false
    else
      raise "Brainfuck: undefined operation"
    end
  end

  def lt(dst, src_l, src_r)
    @bf.comment "dst = src_l < src_r" if @verbose
    _lt(dst, src_l, src_r)
  end

  # FIXME
  def _lt(dst, src_l, src_r)
    return alloc_tmp { |tmp| set tmp, src_l; lt dst, tmp, src_r } if src_l.is_a? Integer
    return alloc_tmp { |tmp| set tmp, src_r; lt dst, src_l, tmp } if src_r.is_a? Integer
    alloc_tmps(2) do |a, b|
      _copy a, src_l
      _copy b, src_r
      _zero dst
      _times(b) do
        _if_zero(a) do
          _addsub_const ?+, dst, 1
        end
        _addsub_const ?+, a, 1
      end
      _zero a
    end
  end

  # -- 論理演算 --

  def not(dst, verbose = @verbose)
    @bf.comment "#{dst} = not #{dst}" if verbose
    alloc_tmp do |tmp|
      _add_const tmp, 1
      go_to dst
      @bf << "["
        _add_const tmp, -1
        _zero dst
        go_to dst
      @bf << "]"
      _move dst, tmp
    end
  end

  # -- 制御 --

  def _times(src)
    go_to src
    @bf << "["
      @bf.indent += 1
      @bf.newline
      yield
      @bf.indent -= 1
      @bf.newline
      go_to src
    @bf << "-]"
  end

  def times!(src, &block)
    @bf.comment "for #{src} = #{src} downto 1:"
    _times(src, &block)
  end

  def times(src, tmp = nil, &block)
    return alloc_tmp { |ptr| times(src, ptr, &block) } unless tmp
    @bf.comment "for #{tmp} = #{src} downto 1:"
    _copy tmp, src
    _times(tmp, &block)
  end

  def while_nonzero(src, &block)
    @bf.comment "while #{src} != 0:" if @verbose
    _while_nonzero(src, &block)
  end

  def _while_nonzero(src)
    alloc_tmp do |tmp|
      _copy tmp, src
      go_to tmp
      @bf << "["
        @bf.indent += 1
        @bf.newline
        yield
        @bf.indent -= 1
        @bf.newline
        _copy tmp, src
        go_to tmp
      @bf << "]"
    end
  end

  def while_zero(src, &block)
    @bf.comment "while #{src} == 0:" if @verbose
    _while_zero(src, &block)
  end

  def _while_zero(src)
    alloc_tmp do |tmp|
      _copy tmp, src
      self.not tmp
      go_to tmp
      @bf << "["
        @bf.indent += 1
        @bf.newline
        yield
        @bf.indent -= 1
        @bf.newline
        _copy tmp, src
        self.not tmp
        go_to tmp
      @bf << "]"
    end
  end

  def if_nonzero(src, &block)
    @bf.comment "if #{src} != 0:" if @verbose
    _if_nonzero(src, &block)
  end

  def _if_nonzero(src)
    alloc_tmp do |tmp|
      _copy tmp, src  
      go_to tmp
      @bf << "["
        @bf.indent += 1
        @bf.newline
        yield
        @bf.indent -= 1
        @bf.newline
        go_to tmp
        @bf << "[-]"
      @bf << "]"
    end
  end

  def if_zero(src, &block)
    @bf.comment "if #{src} == 0:" if @verbose
    _if_zero(src, &block)
  end

  def _if_zero(src, &block)
    alloc_tmp do |tmp|
      _copy tmp, src
      self.not tmp, false
      _if_nonzero tmp, &block
      _zero tmp
    end
  end

  # -- 入出力 --

  # 文字列を出力する
  # 文字列にはヌル文字が含まれてはいけない
  def print(src, verbose = @verbose)
    @bf.comment "print #{src.inspect}" if verbose
    alloc_tmp(src.size + 1) do |tmp|
      setstr tmp, src, nil, false
      _zero tmp[src.size]

      # putchar until 0
      go_to tmp
      @bf << "[.>]"
      @pointer += src.size

      # clear mem
      go_to tmp
      @bf << "[[-]>]"
      @pointer += src.size
    end
  end

  # 文字列を出力して改行する
  def puts(src, verbose = @verbose)
    @bf.comment "puts #{src.inspect}" if verbose
    print src, false
    alloc_tmp do |tmp|
      _set tmp, ?\n
      putchar tmp, false
      _zero tmp
    end
  end

  def putchar(src, verbose = @verbose)
    @bf.comment "putchar #{src}" if verbose
    go_to src
    @bf << ?.
  end

  def putdigit(src, verbose = @verbose)
    @bf.comment "putdigit #{src}" if verbose
    _add_const src, ?0.ord
    go_to src
    @bf << ?.
    _add_const src, -?0.ord
  end

  def putstr(src, len = nil, verbose = @verbose)
    if src.is_a? Ptr
      len ||= src.size
    else
      len ||= 1
    end

    @bf.comment "putstr #{src}" if verbose

    len.times do |i|
      go_to src, i
      @bf << ?.
    end
  end

  def getstr(dst, len = nil, verbose = @verbose)
    len ||= dst.size
    @bf.comment "#{dst[0, len]} = getstr" if verbose
    len.times do |i|
      getchar dst[i], false
    end
  end

  def setstr(dst, src, len = nil, verbose = @verbose)
    case src
    when String, Array
      len ||= [dst.size, src.size].min
      @bf.comment "#{dst[0, len]} = #{src[0, len].inspect}" if verbose
      _copy(dst[0, len], src[0, len])
    when Ptr
      len ||= [dst.size, src.size].min
      @bf.comment "#{dst[0, len]} = #{src[0, len]}" if verbose
      _copy(dst[0, len], src[0, len])
    end
  end

  def getchar(dst, verbose = @verbose)
    @bf.comment "#{dst} = getchar" if verbose
    go_to dst
    @bf << ?,
  end

  def getdigit(dst, verbose = @verbose)
    @bf.comment "#{dst} = getdigit" if verbose
    go_to dst
    @bf << ?,
    _add_const dst, -?0.ord
  end
end
