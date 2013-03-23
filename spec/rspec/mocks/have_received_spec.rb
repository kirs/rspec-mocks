require 'spec_helper'

module RSpec
  module Mocks
    describe HaveReceived do
      describe "expect(...).to have_received" do
        it 'passes when the double has received the given message' do
          dbl = double_with_met_expectation(:expected_method)
          expect(dbl).to have_received(:expected_method)
        end

        it 'fails when the double has not received the given message' do
          dbl = double_with_unmet_expectation(:expected_method)

          expect {
            expect(dbl).to have_received(:expected_method)
          }.to raise_error(/expected: 1 time/)
        end

        it 'fails when the method has not been previously stubbed' do
          dbl = double

          expect {
            expect(dbl).to have_received(:expected_method)
          }.to raise_error(/method has not been stubbed/)
        end

        context "with" do
          it 'passes when the given args match the args used with the message' do
            dbl = double_with_met_expectation(:expected_method, :expected, :args)
            expect(dbl).to have_received(:expected_method).with(:expected, :args)
          end

          it 'fails when the given args do not match the args used with the message' do
            dbl = double_with_met_expectation(:expected_method, :expected, :args)

            expect {
              expect(dbl).to have_received(:expected_method).with(:unexpected, :args)
            }.to raise_error(/expected: 1 time/) # TODO: better failure message
          end
        end

        context "counts" do
          let(:dbl) { double(:expected_method => nil) }

          before do
            dbl.expected_method
            dbl.expected_method
            dbl.expected_method
          end

          context "exactly" do
            it 'passes when the message was received the given number of times' do
              expect(dbl).to have_received(:expected_method).exactly(3).times
            end

            it 'fails when the message was received more times' do
              expect {
                expect(dbl).to have_received(:expected_method).exactly(2).times
              }.to raise_error(/expected: 2 times.*received: 3 times/m)
            end

            it 'fails when the message was received fewer times' do
              expect {
                expect(dbl).to have_received(:expected_method).exactly(4).times
              }.to raise_error(/expected: 4 times.*received: 3 times/m)
            end
          end

          context 'at_least' do
            it 'passes when the message was received the given number of times' do
              expect(dbl).to have_received(:expected_method).at_least(3).times
            end

            it 'passes when the message was received more times' do
              expect(dbl).to have_received(:expected_method).at_least(2).times
            end

            it 'fails when the message was received fewer times' do
              expect {
                expect(dbl).to have_received(:expected_method).at_least(4).times
              }.to raise_error(/expected: 4 times.*received: 3 times/m) # TODO: better message
            end
          end

          context 'at_most' do
            it 'passes when the message was received the given number of times' do
              expect(dbl).to have_received(:expected_method).at_most(3).times
            end

            it 'passes when the message was received fewer times' do
              expect(dbl).to have_received(:expected_method).at_most(4).times
            end

            it 'fails when the message was received more times' do
              expect {
                expect(dbl).to have_received(:expected_method).at_most(2).times
              }.to raise_error(/expected: 2 times.*received: 3 times/m) # TODO: better message
            end
          end

          context 'once' do
            it 'passes when the message was received once' do
              dbl = double(:expected_method => nil)
              dbl.expected_method
              expect(dbl).to have_received(:expected_method).once
            end

            it 'fails when the message was never received' do
              dbl = double(:expected_method => nil)

              expect {
                expect(dbl).to have_received(:expected_method).once
              }.to raise_error(/expected: 1 time.*received: 0 times/m)
            end

            it 'fails when the message was received twice' do
              dbl = double(:expected_method => nil)
              dbl.expected_method
              dbl.expected_method

              expect {
                expect(dbl).to have_received(:expected_method).once
              }.to raise_error(/expected: 1 time.*received: 2 times/m)
            end
          end

          context 'twice' do
            it 'passes when the message was received twice' do
              dbl = double(:expected_method => nil)
              dbl.expected_method
              dbl.expected_method

              expect(dbl).to have_received(:expected_method).twice
            end

            it 'fails when the message was received once' do
              dbl = double(:expected_method => nil)
              dbl.expected_method

              expect {
                expect(dbl).to have_received(:expected_method).twice
              }.to raise_error(/expected: 2 times.*received: 1 time/m)
            end

            it 'fails when the message was received thrice' do
              dbl = double(:expected_method => nil)
              dbl.expected_method
              dbl.expected_method
              dbl.expected_method

              expect {
                expect(dbl).to have_received(:expected_method).twice
              }.to raise_error(/expected: 2 times.*received: 3 times/m)
            end
          end
        end
      end

      describe "expect(...).not_to have_received" do
        it 'passes when the double has not received the given message' do
          dbl = double_with_unmet_expectation(:expected_method)
          expect(dbl).not_to have_received(:expected_method)
        end

        it 'fails when the double has received the given message' do
          dbl = double_with_met_expectation(:expected_method)

          expect {
            expect(dbl).not_to have_received(:expected_method)
          }.to raise_error(/expected: 0 times.*received: 1 time/m)
        end

        it 'fails when the method has not been previously stubbed' do
          dbl = double

          expect {
            expect(dbl).not_to have_received(:expected_method)
          }.to raise_error(/method has not been stubbed/)
        end

        context "with" do
          it 'passes when the given args do not match the args used with the message' do
            dbl = double_with_met_expectation(:expected_method, :expected, :args)
            expect(dbl).not_to have_received(:expected_method).with(:unexpected, :args)
          end

          it 'fails when the given args match the args used with the message' do
            dbl = double_with_met_expectation(:expected_method, :expected, :args)

            expect {
              expect(dbl).not_to have_received(:expected_method).with(:expected, :args)
            }.to raise_error(/expected: 0 times.*received: 1 time/m) # TODO: better message
          end
        end

        it 'does not allow count constraints to be used because it creates confusion'
      end

      def double_with_met_expectation(method_name, *args)
        double = double_with_unmet_expectation(method_name)
        double.send(method_name, *args)
        double
      end

      def double_with_unmet_expectation(method_name)
        double('double', method_name => true)
      end
    end
  end
end