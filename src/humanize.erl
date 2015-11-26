-module(humanize).
-export([time/1]).


%% time(SomTime) -> "3 weeks ago"
time(Time)           -> humanize_time:relTime(Time, calendar:local_time(), "ago", "from now").


  