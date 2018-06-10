
module MEGAUNI

  struct Route

    # =============================================================================
    # Struct:
    # =============================================================================

    MODELS = Set{Stranger_Root,Inbox_All,Not_Found}

    # =============================================================================
    # Instance:
    # =============================================================================

    getter crumbs  : Token
    getter ctx     : HTTP::Server::Context
    getter slashes : Deque(Token)

    delegate :request, :response, to: @ctx

    def initialize(@ctx)
      path     = ctx.request.path
      @crumbs  = Token.new(path)
      @slashes = if path != "/"
                   @crumbs.split('/')
                 else
                   Deque(Token).new
                 end
    end # === def initialize

    def run
      MODELS.find { |x| x.route!(self) }
    end

    {% for x in %w[get post head].map(&.id) %}
      def {{x}}?
        ctx.request.method == "{{x.upcase}}"
      end

      def {{x}}?(str : String)
        {{x}}? && path == str
      end
    {% end %}


    def path
      ctx.request.path
    end

    def html!(html : String)
      html!
      ctx.response.print html
    end # === macro html

    def html!
      ctx.response.content_type = "text/html; charset=utf-8"
    end # === macro html

    def text!
      ctx.response.content_type = "text/plain"
    end

    def text!(t : String)
      text!
      ctx.response.print t
    end

  end # === module Route

  struct Position
    getter char : Char
    getter index : Int32
    def initialize(@char, @index)
    end # === def initialize
  end # === struct Position

  struct Token
    @positions = Deque(Position).new
    delegate :empty?, :size, to: @positions

    def initialize
    end

    def initialize(raw : String)
      raw.each_char_with_index { |c, i|
        @positions.push Position.new(c, i)
      }
    end # === def initialize

    def push(p : Position)
      @positions.push p
    end

    def [](i : Int32)
      @positions[i]
    end

    def starts_with?(t : Token)
      return false if t.empty?
      t.each_char_with_index { |c, i|
        next if @positions[i]? && @positions[i].char == c
        return false
      }
      true
    end # === def starts_with?

    def matches?(t : Token)
      return false if size != t.size
      @positions.each_with_index { |p, i|
        next if t[i].char == p.char
        return false
      }
      true
    end # === def matches?

    def split(target : Char)
      t = Token.new
      q = Deque(Token).new
      last_i = @positions.size - 1
      @positions.each_with_index { |p, i|
        c = p.char
        if c == target
          if !t.empty?
            q.push t
            t = Token.new
          end
          next
        end

        t.push p
        if last_i == i
          q.push t
        end
      }

      q
    end

  end # === struct Token

  struct Path_Crumbs

    getter path : String
    getter token : Token

    def initialize(@path)
      @token = Token.new(@path)
    end # === def initialize

  end # === struct Path_Crumbs
end # === class MU_ROUTER


