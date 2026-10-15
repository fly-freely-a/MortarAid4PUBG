import json
import tempfile
import unittest
from pathlib import Path

from mortar_tools.settings_store import AppSettings, load_settings, save_settings


class SettingsStoreTests(unittest.TestCase):
    def test_loads_legacy_settings_without_scale_cache(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "settings.json"
            path.write_text(
                json.dumps({"language": "zh", "start_combo_max_interval": 0.8}),
                encoding="utf-8",
            )

            settings = load_settings(str(path), [0.3, 0.5, 0.8])

            self.assertEqual(settings.language, "zh")
            self.assertEqual(settings.start_combo_max_interval, 0.8)
            self.assertIsNone(settings.cached_scale_factor)

    def test_round_trips_scale_cache(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "settings.json"
            save_settings(str(path), AppSettings(cached_scale_factor=1.25))

            settings = load_settings(str(path), [0.3, 0.5, 0.8])

            self.assertEqual(settings.cached_scale_factor, 1.25)

    def test_rejects_invalid_scale_cache(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "settings.json"
            path.write_text(json.dumps({"cached_scale_factor": -1}), encoding="utf-8")

            settings = load_settings(str(path), [0.3, 0.5, 0.8])

            self.assertIsNone(settings.cached_scale_factor)


if __name__ == "__main__":
    unittest.main()
