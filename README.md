# Pure Processing

## Nestor Ortiz & Laura Franco

A compact interactive system that transforms Spotify track data into an audiovisual experience.

Each song in the dataset includes characteristics such as **energy, tempo, danceability, valence, loudness**, and detailed metadata (artist, album, release date, genre, etc.).

### How It Works

-   The program reads one record (one song) at a time from the dataset.
-   The genre (`playlist_genre`) determines which `.wav` file is
    played.\
-   **Valence, Danceability, and Loudness** values are used to build a
    **three‑band visual equalizer**.
-   **Energy** controls the **audio volume** of the track.
-   **Tempo** adjusts the **playback speed** of the melody.
-   
    All genre audio assets (e.g., `afrobeats.wav`, `classical.wav`,
    `rock.wav`, etc.) are included in the project.

### Features

-   Real‑time visualization of musical attributes.
-   Display of key metadata: genre, track name, artist(s), album,
    release date.
-   Audio playback with **Play / Pause / Reset** controls.
-   Progress slider synchronized with the currently playing audio.

### Audio Files

The project includes one `.wav` file per genre present in the dataset,
such as:

    afrobeats.wav, ambient.wav, arabic.wav, blues.wav,
    brazillian.wav, classical.wav, country.wav, electronic.wav,
    folk.wav, gaming.wav, hip-hop.wav, indian.wav, indie.wav,
    j-pop.wav, k-pop.wav, korean.wav, latin.wav, metal.wav,
    other.wav, pop.wav, punk.wav, r&b.wav, rock.wav, turkish.wav

### Execution

1. Clone the repository.
2. Open the sketch in Processing.
3. Open the `main.pd` Pure Data file.
4. Trigger the **listen** message in Pure Data.
5. Run the sketch in Processing.
6. Press the **Play** button to start the visualization and audio.
