require "spec_helper"

describe Backup::Encryptor::Age do
  let(:encryptor) do
    Backup::Encryptor::Age.new do |e|
      e.recipient       = 'myrecipient'
      e.recipients_file = '/my/recipient/file'
    end
  end

  it 'should be a subclass of Encryptor::Base' do
    expect(Backup::Encryptor::Age
      .superclass).to eq(Backup::Encryptor::Base)
  end

  describe '#initialize' do
    after { Backup::Encryptor::Age.clear_defaults! }

    it 'should load pre-configured defaults' do
      expect_any_instance_of(Backup::Encryptor::Age).to receive(:load_defaults!)
      encryptor
    end

    context 'when no pre-configured defaults have been set' do
      it 'should use the values given' do
        expect(encryptor.recipient).to       eq('myrecipient')
        expect(encryptor.recipients_file).to eq('/my/recipient/file')
      end

      it 'should use default values if none are given' do
        encryptor = Backup::Encryptor::Age.new
        expect(encryptor.recipient).to        be_nil
        expect(encryptor.recipients_file).to  be_nil
      end
    end # context 'when no pre-configured defaults have been set'

    context 'when pre-configured defaults have been set' do
      before do
        Backup::Encryptor::Age.defaults do |e|
          e.recipient       = 'default_recipient'
          e.recipients_file = '/default/recipient/file'
        end
      end

      it 'should use pre-configured defaults' do
        encryptor = Backup::Encryptor::Age.new
        expect(encryptor.recipient).to        eq('default_recipient')
        expect(encryptor.recipients_file).to  eq('/default/recipient/file')
      end

      it 'should override pre-configured defaults' do
        expect(encryptor.recipient).to        eq('myrecipient')
        expect(encryptor.recipients_file).to  eq('/my/recipient/file')
      end
    end # context 'when pre-configured defaults have been set'
  end # describe '#initialize'

  describe '#encrypt_with' do
    it 'should yield the encryption command and extension' do
      expect(encryptor).to receive(:log!)
      expect(encryptor).to receive(:utility).with(:age).and_return('age_cmd')
      expect(encryptor).to receive(:options).and_return('cmd_options')

      encryptor.encrypt_with do |command, ext|
        expect(command).to eq('age_cmd cmd_options')
        expect(ext).to eq('.age')
      end
    end
  end

  describe '#options' do
    let(:encryptor) { Backup::Encryptor::Age.new }

    context 'with no options given' do
      it 'should add #recipient option whenever #recipients_file not given' do
        expect(encryptor.send(:options)).to eq("--recipient ''")
      end
    end

    context 'when #recipients_file is given' do
      before { encryptor.recipients_file = 'recipients_file' }

      it 'should add #recipients_file option' do
        expect(encryptor.send(:options)).to eq("--recipients-file recipients_file")
      end

      it 'should add #recipients_file option even when #recipient given' do
        encryptor.recipient = 'recipient'
        expect(encryptor.send(:options)).to eq("--recipients-file recipients_file")
      end
    end

    context 'when #recipient is given (without #recipients_file given)' do
      before { encryptor.recipient = %q(pa\ss'w"ord) }

      it 'should include the given recipient in the #recipient option' do
        expect(encryptor.send(:options)).to eq(%q(--recipient pa\\\ss\'w\"ord))
      end
    end

  end # describe '#options'

end
