# Successful Day Tracker

A daily planner and checklist that runs in the browser. Each person sets up their own roles and weekly schedule, ticks off each time slot, and writes a short reflection every evening.

It's a static site. With Supabase connected, each person signs in and their plan and daily ticks are stored in your Supabase database, so they follow them across devices. Without Supabase, it still works, and data stays in each browser.

## What's in the folder

- `index.html`: the whole app
- `config.js`: your Supabase project URL and anon key go here
- `supabase-schema.sql`: creates the two tables and the privacy rules
- `manifest.webmanifest` and `icon.svg`: let people add it to their phone's home screen

## Connect Supabase (about 10 minutes)

1. **Create the tables.** In your Supabase project, open SQL Editor > New query, paste all of `supabase-schema.sql`, and click Run. You'll get two tables: `plans` (each person's roles and weekly schedule) and `days` (one row per person per day with ticks, reflection and notes). Row-level security is on, so each person can only read and write their own rows.
2. **Copy your keys.** Go to Project Settings > API. Copy the Project URL and the `anon` `public` key into `config.js`. Never use the `service_role` key in this file; that one bypasses the privacy rules.
3. **Set the site URL.** Go to Authentication > URL Configuration. Set Site URL to the address where you'll host the app (for example `https://tracker.example.com`). Confirmation emails link back here.
4. **Decide on email confirmation.** By default, Supabase emails new users a confirmation link before they can sign in. That's the safer setting. If you'd rather let people in immediately, turn off "Confirm email" under Authentication > Providers > Email.

Supabase's built-in email sender is rate-limited (a few emails per hour). If more than a handful of people will sign up, add your own SMTP under Authentication > Emails.

### Seeing the data

Table Editor > `days` shows every reflection and tick by date. You can also query it, for example everyone's completion count for a week:

```sql
select user_id, day, (select count(*) from jsonb_object_keys(done)) as ticked
from days
where day between '2026-10-19' and '2026-10-25'
order by day;
```

## Deploy on your own server

Copy the folder to any web server that serves static files. With nginx:

```nginx
server {
    listen 80;
    server_name tracker.example.com;
    root /var/www/day-tracker;
    index index.html;
}
```

Then reload nginx (`sudo systemctl reload nginx`). Add HTTPS with Let's Encrypt (`sudo certbot --nginx`); phones only offer "Add to Home Screen" as an app over HTTPS.

Apache works the same way: put the folder under your document root.

## Deploy for free, no server

- **Netlify**: drag the folder onto app.netlify.com/drop.
- **GitHub Pages**: push the folder to a repository, then turn on Pages under Settings > Pages.
- **Cloudflare Pages**: create a project and upload the folder.

Each gives you an HTTPS link you can share.

## Try it locally

```bash
cd day-tracker
python3 -m http.server 8000
```

Open http://localhost:8000.

## How people use it

1. Open the link. The app starts with an example schedule.
2. Go to **Plan** to rename roles, pick colours, and edit each weekday's time slots. "Copy this day to" saves time.
3. Use **Settings** to set the start and end dates and add days off (holidays use the "Day off" schedule).
4. On **Today**, tick each slot as it's done and fill in the reflection before bed.

## Things to know

- With Supabase connected, the app saves about a second after each change and shows "Synced" at the top. Offline edits are kept on the device and sent when the connection returns.
- The first time someone signs in, whatever they already had in that browser is uploaded to their account.
- If the same person edits on two devices at once, the last save wins.
- People on the same link never see each other's data. As the project owner, you can see everything in the Supabase dashboard.
- Without Supabase (empty `config.js`), data lives in one browser. **Settings > Download backup** makes a copy either way.
- Fonts load from Google Fonts. Offline, the app falls back to the system font and still works.
