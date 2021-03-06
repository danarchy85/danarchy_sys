
class Accounts
  def self.chooser(danarchysys_config)
    accounts = Helpers.objects_to_numarray(danarchysys_config[:accounts].keys)
    account = 'nil'

    if accounts.count == 1
      account = accounts[1]
      return account
    end      

    fields = PrintFormats.printf_hash(accounts)
    printf("#{fields}\n", 'Id', 'Account')
    accounts.each do |id, account|
      printf("#{fields}\n", "#{id}.", account)
    end

    until accounts.values.include?(account)
      print 'Which account should we use? (enter \'exit\' to leave): '
      account = gets
      account = account ? account.chomp : abort('Exiting!')

      if account =~ /^[0-9]*$/
        account = accounts[account.to_i]
      else
        account = account.to_sym
      end
    end

    account
  end
end
