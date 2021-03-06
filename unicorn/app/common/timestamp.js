// Copyright © 2016, Numenta, Inc.  Unless you have purchased from
// Numenta, Inc. a separate commercial license for this software code, the
// following terms and conditions apply:
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero Public License version 3 as published by the Free
// Software Foundation.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero Public License for more details.
//
// You should have received a copy of the GNU Affero Public License along with
// this program.  If not, see http://www.gnu.org/licenses.
//
// http://numenta.org/licenses/

import moment from 'moment';
const MOMENT_TO_STRPTIME = require('../config/momentjs_to_datetime_strptime.json'); // eslint-disable-line

/**
 * List of supported timestamp formats mapped to python dateutil format
 * @type {string}
 * @see ../config/momentjs_to_datetime_strptime.json
 */
export const TIMESTAMP_FORMAT_PY_MAPPING =
   MOMENT_TO_STRPTIME.reduce((prev, cur) => {
     return Object.assign(prev, cur.mappings);
   }, {});

/**
 * List of supported timestamp formats
 * @type {string}
 */
export const TIMESTAMP_FORMATS = Object.keys(TIMESTAMP_FORMAT_PY_MAPPING);

/**
 * Parse an ISO 8601 timestamp, preserving its current time zone. If there's no
 * time zone, use UTC.
 *
 * This is like `moment.parseZone`, except:
 *
 * - It falls back to UTC instead of local time.
 * - It additionally returns a `hasTimeZone` bool.
 *
 * @param {string} timestamp - an ISO 8601 timestamp
 * @return {Array} - Tuple:
 *                   {Object} - Moment object with the parsed timestamp
 *                   {boolean} - true if timestamp contains time zone info
 */
export function parseIsoTimestampFallbackUtc(timestamp) {
  // If it contains a '+' or '-' or 'Z' after the 'T', it has time zone info.
  let hasTimeZone = /.*T.*(\+|\-|Z).*/.test(timestamp);

  let m;
  if (hasTimeZone) {
    m = moment.parseZone(timestamp);
  } else {
    m = moment.utc(timestamp);
  }

  return [m, hasTimeZone];
}

/**
 * Parse a timestamp, preserving its current time zone. If there's no time zone,
 * use UTC.
 *
 * This is like `moment.parseZone`, except:
 *
 * - It supports format strings.
 * - It falls back to UTC instead of local time.
 * - It additionally returns a `hasTimeZone` bool.
 *
 * @see http://momentjs.com/docs/#/parsing/string-format/
 * @param {string} timestamp - an arbitrary timestamp string
 * @param {string} format - the format of the timestamp
 * @return {Array} - Tuple:
 *                   {Object} - Moment object with the parsed timestamp
 *                   {boolean} - true if timestamp contains time zone info
 */
export function parseTimestampFallbackUtc(timestamp, format) {
  let m = moment.utc(timestamp, format);
  let hasTimeZone = format.indexOf('Z') !== -1;

  if (hasTimeZone) {
    // Configure the object to use the parsed time zone.
    //
    // Note that this is not the same as `moment.parseZone`.
    // It's an undocumented public API that calls `setOffsetToParsedOffset`.
    m.parseZone();
  }

  return [m, hasTimeZone];
}

/**
 * Get a timestamp's numeric value, ignoring its time zone.
 *
 * This is a way of having "naive" datetimes, as in Python. JavaScript Date
 * objects condense the day/hour with the time zone by simply storing the UTC
 * timestamp. We want to preserve the parsed day/hour -- it's what we render --
 * so we preserve it by throwing out time zone info.
 *
 * In other words:
 *
 * - Converting a Moment object to a JavaScript Date is lossy because it
 *   flattens the time zone into UTC, forgetting the literal HH:MM timestamp.
 *   But it preserves the idea of absolute time.
 * - Converting a Moment object to a naive time is lossy because it totally
 *   forgets the time zone. But it preserves the literal HH:MM timestamp.
 *
 * @param {Object} m - a moment.js object
 * @return {number} Milliseconds between
 *                    January 1st, 1970 00:00:00 UTC
 *                  and
 *                    the result of stripping the time zone from m and
 *                    interpreting it as UTC.
 *                  This number is ready for JavaScript's `new Date(n)`.
 */
export function getNaiveTime(m) {
  let noZoneFormat = 'YYYY-MM-DDTHH:mm:ss.SSSSSS';
  let strippedZone = m.format(noZoneFormat);
  return moment.utc(strippedZone, noZoneFormat).valueOf();
}
