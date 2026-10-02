# ISM4421Suno — SunoStudio

A single-page AI music generator built on the [Suno API](https://docs.sunoapi.org).
No build step and no server-side secrets. Each user pastes **their own API key** when they open the page.

## Features
- **Bring your own key**: the key is held only in page memory. It is never written to localStorage, cookies, or any server, and it is gone when the page is refreshed.
- **Credit balance** shown after you connect (`GET /api/v1/generate/credit`).
- **Simple mode**: describe the song in plain English (up to 500 chars).
- **Custom mode**: title, style tags (with quick-pick chips), and your own lyrics.
- **AI lyric writer** (`POST /api/v1/lyrics`) fills the lyrics box for you.
- **Instrumental** toggle, **model** picker (V5, V4.5+, V4.5, V4.5 All, V4, V3.5), **vocal gender**.
- **Advanced**: excluded styles, style weight, and creativity/weirdness.
- **Live progress**: polls `GET /api/v1/generate/record-info` and plays the stream preview as soon as it's ready, then swaps in the final MP3.
- Two variations per request, with an audio player, a download button, lyrics, and a copy-link button for each.
- **Library** of past songs saved on your device (song metadata only, never the key).
- **Light / dark theme** toggle (starts dark; the choice is remembered on the device).
- **Personal welcome**: visitors are asked their name once, and the header becomes "*Name*'s Studio". The name is saved only on that device and can be changed with the ✎ button.
- Custom gradient **equalizer logo** (also used as the favicon). It animates while a track plays.

## Deploy to Netlify
1. In Netlify choose **Add new site → Import from Git**, pick this repo, branch `main`.
2. Leave the build command empty. The publish directory is `.` (already set in `netlify.toml`).
3. Deploy, open the site, paste your key from <https://sunoapi.org/api-key>, and click **Connect**.

`netlify.toml` proxies `/suno/*` to `https://api.sunoapi.org/*` so browser requests are same-origin, which avoids CORS errors.
The user's key passes through that proxy only in the `Authorization` header of each request and is never stored.

## Local development
```bash
npx netlify-cli dev      # runs the /suno proxy locally
```
If you open `index.html` directly from disk, the app calls `api.sunoapi.org` itself. That only works if the API allows CORS.

## Notes
- Suno requires a `callBackUrl`. The app sends `<site>/callback` and polls for results instead of relying on the callback.
- Generated audio URLs are hosted by Suno and expire after a while, so download anything you want to keep.
