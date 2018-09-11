shared_examples_for "an application record" do
  it { is_expected.to respond_to(:mark_as_updated_by_user) }
end
