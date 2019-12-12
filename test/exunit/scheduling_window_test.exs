defmodule SmooshSchedulingWindowTest do
  use Couch.Test.ExUnit.Case

  setup_all(context) do
    test_ctx = :test_util.start_couch([])

    on_exit(fn ->
      :config.delete('smoosh.test_channel', 'from')
      :config.delete('smoosh.test_channel', 'to')
      :test_util.stop_couch(test_ctx)
    end)

    context
  end

  def hh_mm(date_time) do
    {date_time.hour, date_time.minute}
  end

  test "in_allowed_window returns true by default", _context do
    now = DateTime.utc_now()
    assert :smoosh_utils.in_allowed_window(hh_mm(now), 'nonexistent_channel') == true
  end

  test "in_allowed_window ignores bad input", _context do
    now = DateTime.utc_now()
    :config.set('smoosh.test_channel', 'from', 'midnight', false)
    :config.set('smoosh.test_channel', 'to', 'infinity', false)
    assert :smoosh_utils.in_allowed_window(hh_mm(now), 'test_channel') == true
  end

  test "in_allowed_window returns false when now < from < to", _context do
    now = DateTime.utc_now()
    from = DateTime.add(now, 18_000)
    to = DateTime.add(now, 36_000)
    :config.set('smoosh.test_channel', 'from', '#{from.hour}:#{from.minute}', false)
    :config.set('smoosh.test_channel', 'to', '#{to.hour}:#{to.minute}', false)
    assert :smoosh_utils.in_allowed_window(hh_mm(now), 'test_channel') == false
  end

  test "in_allowed_window returns true when from < now < to", _context do
    now = DateTime.utc_now()
    from = DateTime.add(now, -18_000)
    to = DateTime.add(now, 18_000)
    :config.set('smoosh.test_channel', 'from', '#{from.hour}:#{from.minute}', false)
    :config.set('smoosh.test_channel', 'to', '#{to.hour}:#{to.minute}', false)
    assert :smoosh_utils.in_allowed_window(hh_mm(now), 'test_channel') == true
  end

  test "in_allowed_window returns false when from < to < now", _context do
    now = DateTime.utc_now()
    from = DateTime.add(now, -36_000)
    to = DateTime.add(now, -18_000)
    :config.set('smoosh.test_channel', 'from', '#{from.hour}:#{from.minute}', false)
    :config.set('smoosh.test_channel', 'to', '#{to.hour}:#{to.minute}', false)
    assert :smoosh_utils.in_allowed_window(hh_mm(now), 'test_channel') == false
  end

  test "in_allowed_window returns true when to < from < now", _context do
    now = DateTime.utc_now()
    from = DateTime.add(now, -18_000)
    to = DateTime.add(now, -36_000)
    :config.set('smoosh.test_channel', 'from', '#{from.hour}:#{from.minute}', false)
    :config.set('smoosh.test_channel', 'to', '#{to.hour}:#{to.minute}', false)
    assert :smoosh_utils.in_allowed_window(hh_mm(now), 'test_channel') == true
  end

  test "in_allowed_window returns false when to < now < from", _context do
    now = DateTime.utc_now()
    from = DateTime.add(now, 18_000)
    to = DateTime.add(now, -18_000)
    :config.set('smoosh.test_channel', 'from', '#{from.hour}:#{from.minute}', false)
    :config.set('smoosh.test_channel', 'to', '#{to.hour}:#{to.minute}', false)
    assert :smoosh_utils.in_allowed_window(hh_mm(now), 'test_channel') == false
  end

  test "in_allowed_window returns true when now < to < from", _context do
    now = DateTime.utc_now()
    from = DateTime.add(now, 36_000)
    to = DateTime.add(now, 18_000)
    :config.set('smoosh.test_channel', 'from', '#{from.hour}:#{from.minute}', false)
    :config.set('smoosh.test_channel', 'to', '#{to.hour}:#{to.minute}', false)
    assert :smoosh_utils.in_allowed_window(hh_mm(now), 'test_channel') == true
  end
end
