require "nokogiri"
require "net/http"
require "uri"
require "time"
require "facets"

module Watcard
  class History
    def initialize(config)
      @conf = config
    end

    def log(msg)
      STDERR.puts msg
    end

    def history_page(date)
      uri = URI.parse("https://account.watcard.uwaterloo.ca/watgopher661.asp")
      date_txt = date.strftime("%m/%d/%Y")
      args = {
        "acnt_1"=>@conf['id'],
        "acnt_2"=>@conf['pin'],
        "DBDATE"=>date_txt,
        "DEDATE"=>date_txt,
        "PASS"=>"PASS",
        "STATUS"=>"HIST",
        "watgopher_title"=>"WatCard History Report",
        "watgopher_regex"=>'<hr>([\s\S]*wrong[\s\S]*)<p></p>|(<form[\s\S]*?(</center>|</form>))|(<pre><p>[\s\S]*</pre>)',
        "watgopher_style"=>'onecard_narrow',
      }
      log "# Fetching history for #{date}"
      Net::HTTP.post_form(uri, args)
    end

    def parse_loc(loc)
      return "V1 Cafeteria" if loc =~ /WAT-FS-V1/
      return "Liquid Assets" if loc =~ /WAT-FS-LA/
      return "V1 Laundry" if loc =~ /V1 LAUNDRY/
      loc
    end

    def history(date)
      page_body = history_page(date).body
      doc = Nokogiri::HTML(page_body)
      table = doc.css('#oneweb_financial_history_table')
      table.xpath('.//tr').map do |row|
        cols = row.xpath('./td').map(&:inner_text)
        next if cols.length < 4
        mult = (cols[3] == "1") ? 2 : 1
        {
          time: Time.parse(cols[1], date),
          amount: -(cols[2].strip.to_f)*mult,
          loc: parse_loc(cols.last),
          balance: cols[3].to_i
        }
      end.compact.reverse
    end

    def bundle_transactions(hist)
      return hist if hist.empty?
      hist.each do |a|
        h = a[:time].hour
        type = if a[:loc] =~ /laundry/i
          "Laundry"
        elsif h < 11
          "Breakfast"
        elsif h < 17
          "Lunch"
        else
          "Dinner"
        end
        a[:meal] = type
      end
      meals = [hist.shift]
      hist.each do |a|
        # if last meal is same type treat them as one
        if a[:meal] == meals.last[:meal]
          meals.last[:amount] += a[:amount]
        else
          meals << a
        end
      end
      meals
    end

    def add_accounts(hist)
      accounts = @conf['accounts']
      hist.each do |a|
        a[:account] = accounts[a[:balance]] || accounts[4]
      end
    end

    def fetch_meals(days_ago)
      hist = history(Time.now.less(days_ago, :days))
      if hist.empty?
        log "No Transactions"
        exit
      end
      bundle_transactions(hist)
    end

    def ledger_transaction(m)
      date_str = m[:time].strftime("%Y/%m/%d")
      transact = <<END

#{date_str} #{m[:meal]} at #{m[:loc]}
  #{m[:account][0]}  $#{sprintf('%.2f', m[:amount])}
  #{m[:account][1]}
END
    end

    def output_ledger(days_ago)
      meals = fetch_meals(days_ago)
      add_accounts(meals)
      log "# Transactions:"
      out = meals.map {|m| ledger_transaction(m)}.join('')
      puts out
      if STDIN.tty? && @conf['ledger']
        print "# Add to file [yN]: "
        ans = gets.chomp
        exit if ans != "y"
        file = File.expand_path(@conf['ledger'])
        File.open(file, 'a') {|f| f.puts out}
        puts "# Added to #{file}"
      end
    end

    def output_history(days_ago)
      meals = fetch_meals(days_ago)
      total = 0
      meals.each do |m|
        total += m[:amount] if m[:balance] == 1
        puts "#{m[:meal]}: $#{sprintf('%.2f', m[:amount])} @ #{m[:loc]}"
      end
      budget = @conf['budget']
      print "= $#{total}"
      print " out of $#{budget} surplus: #{sprintf('%.2f',budget-total)}" if budget
      puts ''
    end
  end
end
