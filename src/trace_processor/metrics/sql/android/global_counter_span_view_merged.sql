--
-- Copyright 2020 The Android Open Source Project
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     https://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

DROP VIEW IF EXISTS {{table_name}}_span;
CREATE VIEW {{table_name}}_span AS
SELECT
  ts,
  LEAD(ts, 1, (SELECT end_ts + 1 FROM trace_bounds))
      OVER(ORDER BY ts) - ts AS dur,
  CAST(value AS INT) AS {{table_name}}_val
FROM (
    SELECT ts, value, LAG(value) OVER (ORDER BY ts) as lag_value
    FROM counter c JOIN counter_track t
      ON t.id = c.track_id
    WHERE t.type = 'counter_track'
      AND name = '{{counter_name}}'
)
WHERE value != lag_value;
