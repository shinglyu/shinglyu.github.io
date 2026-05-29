//! publish — moves a Jekyll draft to _posts/ with a deterministic timestamp.
//!
//! Usage: publish [-y] <draft_file>
//!   -y  Skip the interactive confirmation prompt (for agent / non-interactive use)
//!
//! Time rules (Europe/Amsterdam timezone):
//!   • On a weekday (Mon–Fri) between 09:00 and 18:00 Amsterdam time the publish
//!     timestamp is moved to 08:30 AM ± a small random jitter (±5 min, hard-capped
//!     below 09:00) so the post is never stamped inside working hours.
//!   • At all other times the current Amsterdam clock time is used verbatim.

use chrono::{DateTime, Datelike, Offset, Timelike};
use chrono_tz::Tz;
use chrono_tz::Europe::Amsterdam;
use rand::Rng;
use std::fs;
use std::io::{self, BufRead, Write};
use std::path::Path;
use std::process::{self, Command};

const WORK_START: u32 = 9 * 60; // 540 min = 09:00
const WORK_END: u32 = 18 * 60; // 1080 min = 18:00

/// Returns `true` when `t` falls inside working hours (Mon–Fri 09:00–18:00).
fn is_work_hours(t: &DateTime<Tz>) -> bool {
    let dow = t.weekday().number_from_monday(); // 1=Mon, 7=Sun
    let total_min = t.hour() * 60 + t.minute();
    dow <= 5 && total_min >= WORK_START && total_min < WORK_END
}

/// Format a `+HH:MM` / `-HH:MM` UTC-offset string for the given datetime.
fn format_offset(t: &DateTime<Tz>) -> String {
    let secs = t.offset().fix().local_minus_utc();
    let abs = secs.unsigned_abs();
    format!(
        "{}{:02}:{:02}",
        if secs >= 0 { '+' } else { '-' },
        abs / 3600,
        (abs % 3600) / 60,
    )
}

/// Compute the publish timestamp string, applying the workday guard when needed.
/// `jitter_minutes` is added to the 08:30 base when in work hours (must be in [-5, 5]).
pub fn compute_timestamp(t: &DateTime<Tz>, jitter_minutes: i32) -> String {
    let offset_str = format_offset(t);
    if is_work_hours(t) {
        let base: i32 = 8 * 60 + 30; // 510 min = 08:30
        let mut adjusted = base + jitter_minutes;
        if adjusted >= WORK_START as i32 {
            adjusted = WORK_START as i32 - 1; // hard cap at 08:59
        }
        let adj_h = adjusted / 60;
        let adj_m = adjusted % 60;
        format!(
            "{} {:02}:{:02}:00 {}",
            t.format("%Y-%m-%d"),
            adj_h,
            adj_m,
            offset_str
        )
    } else {
        format!("{} {}", t.format("%Y-%m-%d %H:%M:%S"), offset_str)
    }
}

/// Replace the `date: …` frontmatter line in `content` with the new timestamp.
pub fn replace_date(content: &str, timestamp: &str) -> String {
    let replaced: Vec<String> = content
        .lines()
        .map(|line| {
            if line.starts_with("date: ") {
                format!("date: {}", timestamp)
            } else {
                line.to_string()
            }
        })
        .collect();
    let mut joined = replaced.join("\n");
    if content.ends_with('\n') {
        joined.push('\n');
    }
    joined
}

fn main() {
    let args: Vec<String> = std::env::args().collect();

    let mut auto_confirm = false;
    let mut file_arg: Option<String> = None;

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "-y" | "--yes" => auto_confirm = true,
            "-h" | "--help" => {
                println!("Usage: publish [-y] <draft_file>");
                process::exit(0);
            }
            arg => {
                if file_arg.is_some() {
                    eprintln!("Unexpected argument: {}", arg);
                    process::exit(1);
                }
                file_arg = Some(arg.to_string());
            }
        }
        i += 1;
    }

    let draft_path = match file_arg {
        Some(ref p) => p.clone(),
        None => {
            eprintln!("Usage: publish [-y] <draft_file>");
            process::exit(1);
        }
    };

    if !Path::new(&draft_path).exists() {
        eprintln!("File {} does not exist", draft_path);
        process::exit(2);
    }

    // ── Timestamp calculation (Amsterdam timezone) ─────────────────────────
    let now_amsterdam = chrono::Utc::now().with_timezone(&Amsterdam);
    let jitter: i32 = rand::thread_rng().gen_range(-5..=5);

    if is_work_hours(&now_amsterdam) {
        let base: i32 = 8 * 60 + 30 + jitter;
        let adj = base.min(WORK_START as i32 - 1);
        eprintln!(
            "Working hours detected: adjusting publish time to {:02}:{:02} Amsterdam time (before work hours)",
            adj / 60,
            adj % 60
        );
    }

    let timestamp = compute_timestamp(&now_amsterdam, jitter);

    // ── Build output path ───────────────────────────────────────────────────
    let date_prefix = now_amsterdam.format("%Y-%m-%d-").to_string();
    let post_basename = Path::new(&draft_path)
        .file_name()
        .expect("draft path has no filename")
        .to_str()
        .expect("filename is not valid UTF-8");
    let output = format!("_posts/{}{}", date_prefix, post_basename);

    // ── Update date: field in a copy of the draft ───────────────────────────
    let content = fs::read_to_string(&draft_path).expect("Failed to read draft file");
    let new_content = replace_date(&content, &timestamp);

    println!("Copying {} to {}", draft_path, output);
    fs::write(&output, &new_content).expect("Failed to write output file");
    println!("Setting the time to {}", timestamp);

    // ── Preview ─────────────────────────────────────────────────────────────
    println!("Is this OK?");
    println!("=========================");
    for line in new_content.lines().take(10) {
        println!("{}", line);
    }
    println!("=========================");

    // ── Confirmation ─────────────────────────────────────────────────────────
    let answer = if auto_confirm {
        "y".to_string()
    } else {
        print!("Enter y or n: ");
        io::stdout().flush().unwrap();
        let mut buf = String::new();
        io::stdin().lock().read_line(&mut buf).unwrap();
        buf.trim().to_string()
    };

    if answer == "y" {
        Command::new("git").args(["add", &output]).status().ok();
        println!("Removing {}", draft_path);
        fs::remove_file(&draft_path).expect("Failed to remove draft");
        Command::new("git")
            .args(["add", "-A", &draft_path])
            .status()
            .ok();
    } else {
        println!("Aborting");
        fs::remove_file(&output).ok();
    }
}

// ── Unit tests ──────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;
    use chrono::TimeZone;

    /// Parse a naive "YYYY-MM-DD HH:MM:SS" string as Amsterdam local time.
    fn ams(s: &str) -> DateTime<Tz> {
        let naive = chrono::NaiveDateTime::parse_from_str(s, "%Y-%m-%d %H:%M:%S").unwrap();
        Amsterdam.from_local_datetime(&naive).unwrap()
    }

    // ── is_work_hours ────────────────────────────────────────────────────────

    #[test]
    fn test_work_hours_tuesday_midday() {
        // 2026-05-26 is a Tuesday, 13:00 is inside work hours
        assert!(is_work_hours(&ams("2026-05-26 13:00:00")));
    }

    #[test]
    fn test_work_hours_monday_start_boundary() {
        // Exactly 09:00 is inside work hours
        assert!(is_work_hours(&ams("2026-05-25 09:00:00")));
    }

    #[test]
    fn test_work_hours_friday_before_start() {
        // 08:59 is outside work hours
        assert!(!is_work_hours(&ams("2026-05-29 08:59:00")));
    }

    #[test]
    fn test_work_hours_friday_at_end_boundary() {
        // 18:00 is outside work hours (WORK_END is exclusive)
        assert!(!is_work_hours(&ams("2026-05-29 18:00:00")));
    }

    #[test]
    fn test_work_hours_saturday() {
        // Weekends are never work hours
        assert!(!is_work_hours(&ams("2026-05-30 11:00:00")));
    }

    #[test]
    fn test_work_hours_sunday() {
        assert!(!is_work_hours(&ams("2026-05-31 10:00:00")));
    }

    // ── compute_timestamp ────────────────────────────────────────────────────

    #[test]
    fn test_timestamp_outside_work_hours_uses_current_time() {
        // Saturday 10:30 → timestamp should reflect actual time
        let t = ams("2026-05-30 10:30:45");
        let ts = compute_timestamp(&t, 0);
        // Europe/Amsterdam in summer is UTC+2
        assert_eq!(ts, "2026-05-30 10:30:45 +02:00");
    }

    #[test]
    fn test_timestamp_during_work_hours_zero_jitter() {
        // Tuesday 14:00 with zero jitter → 08:30
        let t = ams("2026-05-26 14:00:00");
        let ts = compute_timestamp(&t, 0);
        assert_eq!(ts, "2026-05-26 08:30:00 +02:00");
    }

    #[test]
    fn test_timestamp_during_work_hours_positive_jitter() {
        // Tuesday 14:00 with jitter +3 → 08:33
        let t = ams("2026-05-26 14:00:00");
        let ts = compute_timestamp(&t, 3);
        assert_eq!(ts, "2026-05-26 08:33:00 +02:00");
    }

    #[test]
    fn test_timestamp_during_work_hours_negative_jitter() {
        // Tuesday 14:00 with jitter -5 → 08:25
        let t = ams("2026-05-26 14:00:00");
        let ts = compute_timestamp(&t, -5);
        assert_eq!(ts, "2026-05-26 08:25:00 +02:00");
    }

    #[test]
    fn test_timestamp_safety_cap_prevents_0900() {
        // Jitter so large it would reach/exceed 09:00 → hard-capped to 08:59
        let t = ams("2026-05-26 14:00:00");
        let ts = compute_timestamp(&t, 100); // 08:30 + 100 = 10:10 → capped
        assert_eq!(ts, "2026-05-26 08:59:00 +02:00");
    }

    #[test]
    fn test_timestamp_winter_offset() {
        // January is UTC+1 (CET), not UTC+2 (CEST)
        let t = ams("2026-01-15 10:00:00");
        let ts = compute_timestamp(&t, 0);
        assert_eq!(ts, "2026-01-15 08:30:00 +01:00");
    }

    // ── replace_date ─────────────────────────────────────────────────────────

    #[test]
    fn test_replace_date_updates_frontmatter() {
        let content = "---\nlayout: post\ndate: 2010-01-01 00:00:00 +08:00\ntitle: Test\n---\nBody.\n";
        let result = replace_date(content, "2026-05-26 08:30:00 +02:00");
        assert!(result.contains("date: 2026-05-26 08:30:00 +02:00"));
        assert!(!result.contains("2010-01-01"));
    }

    #[test]
    fn test_replace_date_preserves_trailing_newline() {
        let content = "date: old\n";
        let result = replace_date(content, "2026-05-26 08:30:00 +02:00");
        assert!(result.ends_with('\n'));
    }

    #[test]
    fn test_replace_date_no_trailing_newline() {
        let content = "date: old";
        let result = replace_date(content, "2026-05-26 08:30:00 +02:00");
        assert!(!result.ends_with('\n'));
    }
}
