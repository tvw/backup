module Backup
  module Encryptor
    class Age < Base

      ##
      # The recipient that'll be used to encrypt the backup. This
      # recipients private key will be required to decrypt the backup
      # later on.
      attr_accessor :recipient

      ##
      # The recipient file to use to encrypt the backup.
      attr_accessor :recipients_file

      ##
      # Creates a new instance of Backup::Encryptor::Age and
      # sets the recipient attribute to what was provided
      def initialize(&block)
        super

        @recipients_file ||= nil

        instance_eval(&block) if block_given?
      end

      ##
      # This is called as part of the procedure run by the Packager.
      # It sets up the needed options to pass to the age command,
      # then yields the command to use as part of the packaging procedure.
      # Once the packaging procedure is complete, it will return
      # so that any clean-up may be performed after the yield.
      def encrypt_with
        log!
        yield "#{utility(:age)} #{options}", '.age'
      end

      private

      ##
      # Always sets a recipient option, if even no recipient is given,
      # but will prefer the recipients_file option if both are given.
      def options
        opts = []

        opts <<
          if @recipients_file.to_s.empty?
            "--recipient #{Shellwords.escape(@recipient)}"
          else
            "--recipients-file #{@recipients_file}"
          end

        opts.join(' ')
      end

    end
  end
end
