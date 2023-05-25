# Bocchi Flutter

So, basically this is an Anime streaming application. It uses `consumet` API under-the-hood for everything from searching to streaming. It uses `animepahe` as the stream provider and `gogoanime` for the info you see on the episode list, like episode title and episode description.

---

## Showcase

<div style = "display:grid; grid-template-columns:repeat(3,1fr); gap:50px;">
<img src = "https://user-images.githubusercontent.com/105339885/218025764-db7f765b-adfc-409f-8544-8beafa5e4280.png" width="30%"/>
<img src = "https://user-images.githubusercontent.com/105339885/218025768-d46f5e82-695b-4fbb-89ae-5c5969de6ded.png" width="30%"/>
<img src = "https://user-images.githubusercontent.com/105339885/218025774-edafcd34-b6fc-4bc1-859d-626b7318c193.png" width="30%"/>
<img src = "https://user-images.githubusercontent.com/105339885/218025778-9178ba8f-0936-40e3-9acd-f9537fc8e8e7.png" width="30%"/>
<img src = "https://user-images.githubusercontent.com/105339885/218025784-49011709-e26f-4d2e-afdd-dabe081e8cf8.png" width="30%"/>
<img src = "https://user-images.githubusercontent.com/105339885/218025753-2cacc438-3602-4608-9f58-e57f2d7ea923.png" width="30%"/>
</div>

---

## Possible improvement

I chose gogoanime to display episode info because animepahe, simply, has no data about episodes, whatsoever. I would have gone with gogoanime's stream service as well, only if it was not broken to begin with. Well, animepahe was also broken but with a little string manipulation, I got it to work😅.

If you were to sacrifice info about episodes like their title and description, this app can be made a LOT faster. Since, I have to fetch both animepahe and gogoanime endpoints, the app is a little slow, but nothing deal-breaking.

---

## Fixing the consumet 403 error

The stream sources from consumet are plain broken. Well, zoro is working but you'll have to manually manage all the soft-subtitles. Well, I got animepahe to work!

TLDR; if you get a url that looks something like this from animepahe-

```
https://eu-{some-three-digit-code}.cache.nextcdn.org/hls/10/08/.../owo.m3u8

https://na-{some-three-digit-code}.cache.nextcdn.org/hls/10/08/.../owo.m3u8
```

just replace the `.cache.` segment with `.files.` It will work like a charm! Finally, it should look something like this-

```
https://eu-{some-three-digit-code}.files.nextcdn.org/hls/10/08/.../owo.m3u8

https://na-{some-three-digit-code}.files.nextcdn.org/hls/10/08/.../owo.m3u8
```
---
That's all, Bye 👋👋👋
