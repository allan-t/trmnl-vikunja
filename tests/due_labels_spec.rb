# frozen_string_literal: true

RSpec.describe 'Full layout' do
  describe 'due date labels' do
    def labels_for(due, **) = render_tasks([build_task(1, due_date: due)], **)

    it('says Today for a due date later today') { expect(labels_for('2030-01-01T18:00:00Z')).to have_text('Today') }
    it('says Tomorrow for the next day') { expect(labels_for('2030-01-02T09:00:00Z')).to have_text('Tomorrow') }
    it('says Overdue 1d for yesterday') { expect(labels_for('2029-12-31T09:00:00Z')).to have_text('Overdue 1d') }
    it('says Overdue 5d for five days ago') { expect(labels_for('2029-12-27T09:00:00Z')).to have_text('Overdue 5d') }
    it('shows an absolute date for far dates') { expect(labels_for('2030-11-12T09:00:00Z')).to have_text('12 Nov') }

    it 'shows no date line for an unset due date' do
      expect(labels_for(UNSET_DUE_DATE)).not_to have_text(/Today|Tomorrow|Overdue|Jan/)
    end

    it 'treats any pre-1970 due date as unset' do
      expect(labels_for('0000-12-30T00:00:00Z')).not_to have_text(/Today|Tomorrow|Overdue|Jan|Dec/)
    end

    describe "in the user's time zone" do
      def offset(seconds) = { trmnl: { user: { utc_offset: seconds } } }

      it 'says Tomorrow when the due date is already the next day locally (east of UTC)' do
        expect(labels_for('2030-01-01T20:00:00Z', variables: offset(10 * 3600))).to have_text('Tomorrow')
      end

      it 'says Today when the due date is still the same day locally (west of UTC)' do
        expect(labels_for('2030-01-01T05:00:00Z', variables: offset(-9 * 3600))).to have_text('Today')
      end

      it 'shows the absolute date in local time' do
        expect(labels_for('2030-11-12T23:00:00Z', variables: offset(10 * 3600))).to have_text('13 Nov')
      end

      it 'falls back to UTC when the offset is not available' do
        expect(labels_for('2030-01-01T20:00:00Z', variables: { trmnl: { user: { utc_offset: nil } } }))
          .to have_text('Today')
      end
    end
  end
end
